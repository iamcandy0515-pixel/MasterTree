import { Request, Response } from "express";
import { GoogleDriveService } from "./google_drive.service";
import { settingsService } from "../settings/settings.service";

const driveService = new GoogleDriveService();

export const searchGoogleImage = async (req: Request, res: Response) => {
    try {
        // Assume treeName and imageType are passed in query params or body
        const { treeName, imageType } = req.body;

        if (!treeName || !imageType) {
            return res
                .status(400)
                .json({ error: "Missing treeName or imageType" });
        }

        const url = await driveService.searchImage(treeName, imageType);

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

        // Extremely naive ID extraction (try to get id parameter or last path segment)
        let folderId = "";
        try {
            const urlObj = new URL(folderUrl);
            const idParam = urlObj.searchParams.get("id");
            if (idParam) {
                folderId = idParam;
            } else {
                const parts = urlObj.pathname.split("/");
                folderId = parts[parts.length - 1];
            }
        } catch (e) {
            folderId = folderUrl.split("/").pop() || "";
        }

        if (!folderId || folderId.length < 10) {
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

        const buffer = await driveService.searchAndDownloadImage(
            treeName,
            imageType,
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
