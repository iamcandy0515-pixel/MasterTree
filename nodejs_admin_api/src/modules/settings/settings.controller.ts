import { Request, Response } from "express";
import { settingsService } from "./settings.service";
import { successResponse, errorResponse } from "../../utils/response";
import axios from "axios";

export class SettingsController {
    static async getEntryCode(req: Request, res: Response) {
        try {
            const data = await settingsService.getEntryCode();
            successResponse(res, { entryCode: data || "1234" });
        } catch (error: any) {
            // If table doesn't exist, we might get an error.
            // But let's assume it works or we fallback
            if (error.code === "42P01") {
                // undefined_table
                successResponse(
                    res,
                    { entryCode: "1234" },
                    "Using default (table missing)",
                );
                return;
            }
            errorResponse(res, error.message || "Failed to get entry code");
        }
    }

    static async updateEntryCode(req: Request, res: Response) {
        try {
            const { entryCode } = req.body;
            if (!entryCode) {
                return errorResponse(res, "Entry code is required", 400);
                return;
            }

            const updated = await settingsService.updateEntryCode(entryCode);
            successResponse(
                res,
                { entryCode: updated },
                "Entry code updated successfully",
            );
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to update entry code");
        }
    }
    static async getUserAppUrl(req: Request, res: Response) {
        try {
            const data = await settingsService.getUserAppUrl();
            successResponse(res, { url: data });
        } catch (error: any) {
            if (error.code === "42P01") {
                successResponse(
                    res,
                    { url: "http://localhost:8080" },
                    "Using default (table missing)",
                );
                return;
            }
            errorResponse(res, error.message || "Failed to get user app url");
        }
    }

    static async updateUserAppUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (!url) {
                return errorResponse(res, "URL is required", 400);
            }

            const updated = await settingsService.updateUserAppUrl(url);
            successResponse(
                res,
                { url: updated },
                "User app url updated successfully",
            );
        } catch (error: any) {
            errorResponse(
                res,
                error.message || "Failed to update user app url",
            );
        }
    }

    static async getGoogleDriveFolderUrl(req: Request, res: Response) {
        try {
            const data = await settingsService.getGoogleDriveFolderUrl();
            successResponse(res, { url: data || "" });
        } catch (error: any) {
            if (error.code === "42P01") {
                successResponse(
                    res,
                    { url: "" },
                    "Using default (table missing)",
                );
                return;
            }
            errorResponse(
                res,
                error.message || "Failed to get google drive folder url",
            );
        }
    }

    static async updateGoogleDriveFolderUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            // Allow empty string if user wants to clear it
            if (url === undefined) {
                return errorResponse(res, "URL is required", 400);
            }

            const updated =
                await settingsService.updateGoogleDriveFolderUrl(url);
            successResponse(
                res,
                { url: updated },
                "Google Drive folder url updated successfully",
            );
        } catch (error: any) {
            errorResponse(
                res,
                error.message || "Failed to update google drive folder url",
            );
        }
    }

    static async getThumbnailDriveUrl(req: Request, res: Response) {
        try {
            const data = await settingsService.getThumbnailDriveUrl();
            successResponse(res, { url: data || "" });
        } catch (error: any) {
            if (error.code === "42P01") {
                successResponse(res, { url: "" });
                return;
            }
            errorResponse(
                res,
                error.message || "Failed to get thumbnail drive url",
            );
        }
    }

    static async updateThumbnailDriveUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (url === undefined) {
                return errorResponse(res, "URL is required", 400);
            }

            const updated = await settingsService.updateThumbnailDriveUrl(url);
            successResponse(
                res,
                { url: updated },
                "Thumbnail drive url updated successfully",
            );
        } catch (error: any) {
            errorResponse(
                res,
                error.message || "Failed to update thumbnail drive url",
            );
        }
    }

    static async getExamDriveUrl(req: Request, res: Response) {
        try {
            const data = await settingsService.getExamDriveUrl();
            successResponse(res, { url: data || "" });
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to get exam drive url");
        }
    }

    static async updateExamDriveUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (url === undefined) {
                return errorResponse(res, "URL is required", 400);
            }

            const updated = await settingsService.updateExamDriveUrl(url);
            successResponse(
                res,
                { url: updated },
                "Exam drive url updated successfully",
            );
        } catch (error: any) {
            errorResponse(
                res,
                error.message || "Failed to update exam drive url",
            );
        }
    }

    static async validateUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (!url) {
                return errorResponse(res, "URL is required", 400);
            }

            // 구글 드라이브 및 기타 외부 URL을 HEAD로 요청하여 생존 확인
            const response = await axios.head(url, { timeout: 5000 });
            const isValid = response.status >= 200 && response.status < 400;
            
            successResponse(res, { isValid });
        } catch (error: any) {
            // timeout, CORS (서버에서는 안 걸림), 404 등등의 에러 처리
            successResponse(res, { isValid: false });
        }
    }
}
