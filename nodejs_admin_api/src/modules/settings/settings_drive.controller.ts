import { Request, Response } from "express";
import { settingsDriveService } from "./settings_drive.service";
import { successResponse, errorResponse } from "../../utils/response";
import axios from "axios";

export class SettingsDriveController {
    static async getGoogleDriveFolderUrl(req: Request, res: Response) {
        try {
            const data = await settingsDriveService.getGoogleDriveFolderUrl();
            successResponse(res, { url: data || "" });
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to get google drive folder url");
        }
    }

    static async updateGoogleDriveFolderUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (url === undefined) return errorResponse(res, "URL is required", 400);

            const updated = await settingsDriveService.updateGoogleDriveFolderUrl(url);
            successResponse(res, { url: updated }, "Google Drive folder url updated successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to update google drive folder url");
        }
    }

    static async getThumbnailDriveUrl(req: Request, res: Response) {
        try {
            const data = await settingsDriveService.getThumbnailDriveUrl();
            successResponse(res, { url: data || "" });
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to get thumbnail drive url");
        }
    }

    static async updateThumbnailDriveUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (url === undefined) return errorResponse(res, "URL is required", 400);

            const updated = await settingsDriveService.updateThumbnailDriveUrl(url);
            successResponse(res, { url: updated }, "Thumbnail drive url updated successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to update thumbnail drive url");
        }
    }

    static async getExamDriveUrl(req: Request, res: Response) {
        try {
            const data = await settingsDriveService.getExamDriveUrl();
            successResponse(res, { url: data || "" });
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to get exam drive url");
        }
    }

    static async updateExamDriveUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (url === undefined) return errorResponse(res, "URL is required", 400);

            const updated = await settingsDriveService.updateExamDriveUrl(url);
            successResponse(res, { url: updated }, "Exam drive url updated successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to update exam drive url");
        }
    }

    static async validateUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (!url) return errorResponse(res, "URL is required", 400);

            const response = await axios.head(url, { timeout: 5000 });
            const isValid = response.status >= 200 && response.status < 400;
            successResponse(res, { isValid });
        } catch (error: any) {
            successResponse(res, { isValid: false });
        }
    }
}
