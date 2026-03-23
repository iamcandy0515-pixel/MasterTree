import { Request, Response } from "express";
import { GoogleDriveService } from "../google_drive.service";
import { externalHelperService } from "../services/external_helper.service";
import { googleDriveFileService } from "../google_drive_file.service";

const driveService = new GoogleDriveService();

/**
 * Controller for Google Drive file search and link management.
 */
export const GoogleDriveController = {
    /**
     * Search for images by tree name and type in Drive.
     */
    searchGoogleImage: async (req: Request, res: Response) => {
        try {
            const { treeName, imageType } = req.body;
            if (!treeName || !imageType) return res.status(400).json({ error: "Missing treeName or imageType" });

            const folderId = await externalHelperService.getFolderIdFromSettings("original");
            if (!folderId) return res.json({ success: false, message: "Drive folder not configured or invalid." });

            const url = await driveService.searchImage(treeName, imageType, folderId);
            return url ? res.json({ success: true, url }) : res.json({ success: false, message: "Image not found." });
        } catch (error) {
            console.error("Search Image Error:", error);
            return res.status(500).json({ error: "Internal Server Error" });
        }
    },

    /**
     * Keyword search for any files in configured folder.
     */
    searchGoogleDriveFiles: async (req: Request, res: Response) => {
        try {
            const { keyword } = req.body;
            if (!keyword) return res.status(400).json({ error: "Missing keyword" });

            const folderId = await externalHelperService.getFolderIdFromSettings("original");
            if (!folderId) return res.status(400).json({ error: "Drive folder not configured." });

            const files = await driveService.searchFilesInFolder(folderId, keyword);
            return res.json({ success: true, data: files });
        } catch (error) {
            console.error("Search Files Error:", error);
            return res.status(500).json({ error: "Internal Server Error" });
        }
    },

    /**
     * Check if a specific Drive file URL still exists.
     */
    checkFileExists: async (req: Request, res: Response) => {
        try {
            const { url } = req.body;
            if (!url) return res.status(400).json({ error: "Missing url" });

            const fileId = externalHelperService.getFileId(url);
            if (!fileId) return res.json({ success: true, exists: false });

            try {
                await googleDriveFileService.getDrive().files.get({ fileId, fields: "id" });
                return res.json({ success: true, exists: true });
            } catch (e: any) {
                if (e.code === 404) return res.json({ success: true, exists: false });
                throw e;
            }
        } catch (error: any) {
            return res.status(500).json({ error: "Check failed", details: error.message });
        }
    },

    /**
     * Get all original and thumbnail links for a tree name.
     */
    getDriveLinks: async (req: Request, res: Response) => {
        try {
            const { treeName } = req.body;
            if (!treeName) return res.status(400).json({ error: "Missing treeName" });

            const originalId = await externalHelperService.getFolderIdFromSettings("original");
            const thumbId = await externalHelperService.getFolderIdFromSettings("thumbnail");

            if (!originalId) return res.status(400).json({ error: "Original drive folder not configured." });

            const originalLinks = await driveService.searchAllLinks(treeName, originalId);
            const thumbLinks = thumbId ? await driveService.searchAllLinks(treeName, thumbId) : {};

            return res.json({ success: true, original: originalLinks, thumb: thumbLinks });
        } catch (error) {
            console.error("Get Drive Links Error:", error);
            return res.status(500).json({ error: "Failed to fetch drive links" });
        }
    }
};
