import { Request, Response } from "express";
import sharp from "sharp";
import { GoogleDriveService } from "../google_drive.service";
import { googleDriveFileService } from "../google_drive_file.service";
import { UploadService } from "../../uploads/uploads.service";
import { externalHelperService } from "../services/external_helper.service";

const driveService = new GoogleDriveService();

/**
 * Controller for image processing, thumbnail generation, and storage sync.
 */
export const ImageManagementController = {
    /**
     * Download an image and return as base64 string.
     */
    searchAndDownloadGoogleImage: async (req: Request, res: Response) => {
        try {
            const { treeName, imageType } = req.body;
            if (!treeName || !imageType) return res.status(400).json({ error: "Missing parameters" });

            const folderId = await externalHelperService.getFolderIdFromSettings("original");
            if (!folderId) return res.status(400).json({ error: "Drive folder not configured." });

            const buffer = await driveService.searchAndDownloadImage(treeName, imageType, folderId);
            if (!buffer) return res.json({ success: false, message: "Image not found" });

            return res.json({ success: true, image: buffer.toString("base64") });
        } catch (error: any) {
            console.error("Download Error:", error);
            if (error.code === 403 || (error.response?.status === 403)) {
                return res.status(403).json({ error: "Google Drive API Access Denied." });
            }
            return res.status(500).json({ error: "Download failed", details: error.message });
        }
    },

    /**
     * Download from Drive and upload to Supabase Storage.
     */
    searchAndAttachGoogleImage: async (req: Request, res: Response) => {
        try {
            const { treeName, imageType } = req.body;
            if (!treeName || !imageType) return res.status(400).json({ error: "Missing parameters" });

            const folderId = await externalHelperService.getFolderIdFromSettings("original");
            if (!folderId) return res.status(400).json({ error: "Drive folder not configured." });

            const buffer = await driveService.searchAndDownloadImage(treeName, imageType, folderId);
            if (!buffer) return res.json({ success: false, message: "Image not found" });

            const typeMap = externalHelperService.getTypeMap();
            const fileName = `${treeName}_${typeMap[imageType] || imageType}_google.jpg`;

            const uploadResult = await UploadService.uploadToStorage(
                { buffer, mimetype: "image/jpeg", originalname: fileName, size: buffer.length } as any,
                "tree-images",
                "trees/google"
            );

            return res.json({ success: true, url: uploadResult.publicUrl, source: "google_drive" });
        } catch (error: any) {
            console.error("SearchAndAttach Error:", error);
            return res.status(500).json({ error: "Search and attach failed", details: error.message });
        }
    },

    /**
     * Resize image, convert to WebP, and upload to Drive thumbnail folder.
     */
    generateThumbnail: async (req: Request, res: Response) => {
        try {
            const { treeName, imageType } = req.body;
            if (!treeName || !imageType) return res.status(400).json({ error: "Missing parameters" });

            const originalId = await externalHelperService.getFolderIdFromSettings("original");
            const thumbId = await externalHelperService.getFolderIdFromSettings("thumbnail");

            if (!originalId || !thumbId) return res.status(400).json({ error: "Drive folders not configured." });

            const originalBuffer = await driveService.searchAndDownloadImage(treeName, imageType, originalId);
            if (!originalBuffer) return res.status(404).json({ error: "Original image not found." });

            const thumbBuffer = await sharp(originalBuffer).resize(400, 400, { fit: "cover" }).webp({ quality: 80 }).toBuffer();
            const typeMap = externalHelperService.getTypeMap();
            const fileName = `${treeName}_${typeMap[imageType] || imageType}_thumb.webp`;

            const uploadRes = await googleDriveFileService.createFile(
                fileName,
                thumbId,
                "image/webp",
                require("stream").Readable.from(thumbBuffer)
            );

            if (uploadRes.data.id) {
                return res.json({ success: true, url: `https://drive.google.com/uc?export=view&id=${uploadRes.data.id}` });
            }
            throw new Error("Failed to upload thumbnail.");
        } catch (error: any) {
            console.error("Thumbnail Error:", error);
            return res.status(500).json({ error: "Failed to generate thumbnail", details: error.message });
        }
    }
};
