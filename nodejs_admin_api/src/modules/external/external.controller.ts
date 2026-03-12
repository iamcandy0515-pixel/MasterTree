import { Request, Response } from "express";
import { GoogleDriveService } from "./google_drive.service";
import { settingsService } from "../settings/settings.service";
import { extractDriveFolderId } from "../../utils/drive-helper";
import sharp from "sharp";
import { googleDriveFileService } from "./google_drive_file.service";

const driveService = new GoogleDriveService();

export const searchGoogleImage = async (req: Request, res: Response) => {
    try {
        const { treeName, imageType } = req.body;

        if (!treeName || !imageType) {
            return res
                .status(400)
                .json({ error: "Missing treeName or imageType" });
        }

        // 1. Fetch Folder URL from Settings
        const folderUrl = await settingsService.getGoogleDriveFolderUrl();
        if (!folderUrl) {
            return res.json({
                success: false,
                message: "Google Drive folder is not configured.",
            });
        }

        // 2. Extract Folder ID
        const folderId = extractDriveFolderId(folderUrl);
        if (!folderId) {
            return res.json({
                success: false,
                message: "Invalid Google Drive folder URL in settings.",
            });
        }

        // 3. Search using dynamic ID
        const url = await driveService.searchImage(
            treeName,
            imageType,
            folderId,
        );

        if (url) {
            return res.json({ success: true, url });
        } else {
            return res.json({
                success: false,
                message: "Image not found matching criteria.",
            });
        }
    } catch (error) {
        console.error("External API Error:", error);
        return res.status(500).json({ error: "Internal Server Error" });
    }
};

export const searchGoogleDriveFiles = async (req: Request, res: Response) => {
    try {
        const { keyword } = req.body;
        if (!keyword) {
            return res.status(400).json({ error: "Missing keyword" });
        }

        const folderUrl = await settingsService.getGoogleDriveFolderUrl();
        if (!folderUrl) {
            return res
                .status(getHttpStatusForFolderUrlNotFound())
                .json({
                    error: "Google Drive folder URL is not configured in settings.",
                });
        }

        const folderId = extractDriveFolderId(folderUrl);

        if (!folderId) {
            return res
                .status(400)
                .json({ error: "Invalid Google Drive folder URL." });
        }

        const files = await driveService.searchFilesInFolder(folderId, keyword);

        return res.json({ success: true, data: files });
    } catch (error: any) {
        console.error("External API Error:", error);
        return res.status(500).json({ error: "Internal Server Error" });
    }
};

function getHttpStatusForFolderUrlNotFound() {
    return 400;
}

export const searchAndDownloadGoogleImage = async (
    req: Request,
    res: Response,
) => {
    try {
        const { treeName, imageType } = req.body;
        if (!treeName || !imageType)
            return res.status(400).json({ error: "Missing parameters" });

        // 1. Fetch Folder URL from Settings
        const folderUrl = await settingsService.getGoogleDriveFolderUrl();
        const folderId = folderUrl ? extractDriveFolderId(folderUrl) : null;

        if (!folderId) {
            return res.status(400).json({
                error: "Google Drive folder is not configured or URL is invalid.",
            });
        }

        const buffer = await driveService.searchAndDownloadImage(
            treeName,
            imageType,
            folderId,
        );

        if (buffer) {
            // Return base64 string
            const base64 = buffer.toString("base64");
            return res.json({ success: true, image: base64 });
        } else {
            return res.json({ success: false, message: "Image not found" });
        }
    } catch (error: any) {
        console.error("Download Error:", error);
        if (
            error.code === 403 ||
            (error.response && error.response.status === 403)
        ) {
            // In severe cases of 403, we might want to return a placeholder or null to avoid crashing the UI loop
            console.log("⚠️ Returning 403 to client. API Enablement pending.");
            return res.status(403).json({
                error: "Google Drive API Access Denied. Ensure 'Google Drive API' is enabled for this API Key.",
            });
        }
        return res
            .status(500)
            .json({ error: "Download failed", details: error.message });
    }
};

export const checkFileExists = async (req: Request, res: Response) => {
    try {
        const { url } = req.body;
        if (!url) return res.status(400).json({ error: "Missing url" });

        const fileId = extractDriveFolderId(url); // extractDriveFolderId works for file IDs too if they are in the segment
        // Better helper for general file ID extraction
        const getFileId = (u: string) => {
            if (u.includes("id=")) return u.split("id=")[1].split("&")[0];
            const parts = u.split("/");
            return parts[parts.length - 1];
        };

        const fileIdReal = getFileId(url);
        if (!fileIdReal) return res.json({ success: true, exists: false });

        try {
            await googleDriveFileService.getDrive().files.get({ fileId: fileIdReal, fields: "id" });
            return res.json({ success: true, exists: true });
        } catch (e: any) {
            if (e.code === 404) return res.json({ success: true, exists: false });
            throw e;
        }
    } catch (error: any) {
        return res.status(500).json({ error: "Check failed", details: error.message });
    }
};

export const generateThumbnail = async (req: Request, res: Response) => {
    try {
        const { treeName, imageType } = req.body;
        if (!treeName || !imageType) return res.status(400).json({ error: "Missing parameters" });

        // 1. Get IDs from Settings
        const originalFolderUrl = await settingsService.getGoogleDriveFolderUrl();
        const thumbFolderUrl = await settingsService.getThumbnailDriveUrl();
        
        const originalFolderId = originalFolderUrl ? extractDriveFolderId(originalFolderUrl) : null;
        const thumbFolderId = thumbFolderUrl ? extractDriveFolderId(thumbFolderUrl) : null;

        if (!originalFolderId || !thumbFolderId) {
            return res.status(400).json({ error: "Drive folders (original/thumb) not configured correctly." });
        }

        // 2. Download Original
        const buffer = await driveService.searchAndDownloadImage(treeName, imageType, originalFolderId);
        if (!buffer) return res.status(404).json({ error: "Original image not found for thumbnail generation." });

        // 3. Resize and Convert to WebP
        const thumbBuffer = await sharp(buffer)
            .resize(400, 400, { fit: "cover" })
            .webp({ quality: 80 })
            .toBuffer();

        // 4. Upload to Thumbnail Folder
        const typeMap: any = { main: "대표", flower: "꽃", fruit: "열매", bark: "수피", leaf: "잎" };
        const fileName = `${treeName}_${typeMap[imageType] || imageType}_thumb.webp`;
        
        const uploadResponse = await googleDriveFileService.createFile(
            fileName,
            thumbFolderId,
            "image/webp",
            require("stream").Readable.from(thumbBuffer)
        );

        if (uploadResponse.data.id) {
            const url = `https://drive.google.com/uc?export=view&id=${uploadResponse.data.id}`;
            return res.json({ success: true, url });
        }
        
        throw new Error("Failed to upload thumbnail to Drive.");
    } catch (error: any) {
        console.error("Thumbnail Generation Error:", error);
        return res.status(500).json({ error: "Failed to generate thumbnail", details: error.message });
    }
};

export const getDriveLinks = async (req: Request, res: Response) => {
    try {
        const { treeName } = req.body;
        if (!treeName) return res.status(400).json({ error: "Missing treeName" });

        const originalFolderUrl = await settingsService.getGoogleDriveFolderUrl();
        const thumbFolderUrl = await settingsService.getThumbnailDriveUrl();
        
        const originalFolderId = originalFolderUrl ? extractDriveFolderId(originalFolderUrl) : null;
        const thumbFolderId = thumbFolderUrl ? extractDriveFolderId(thumbFolderUrl) : null;

        if (!originalFolderId) return res.status(400).json({ error: "Original drive folder not configured." });

        const originalLinks = await driveService.searchAllLinks(treeName, originalFolderId);
        let thumbLinks = {};
        
        if (thumbFolderId) {
            thumbLinks = await driveService.searchAllLinks(treeName, thumbFolderId);
        }

        return res.json({ success: true, original: originalLinks, thumb: thumbLinks });
    } catch (error: any) {
        console.error("Get Drive Links Error:", error);
        return res.status(500).json({ error: "Failed to fetch drive links", details: error.message });
    }
};
