import { Request, Response } from "express";
import { GoogleDriveService } from "./google_drive.service";
import { settingsService } from "../settings/settings.service";
import { extractDriveFolderId } from "../../utils/drive-helper";

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
