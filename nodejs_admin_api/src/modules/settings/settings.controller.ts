import { Request, Response } from "express";
import { settingsService } from "./settings.service";
import { successResponse, errorResponse } from "../../utils/response";

export class SettingsController {
    // -------------------------------------------------------------------------
    // 앱 접속 코드 (Entry Code)
    // -------------------------------------------------------------------------

    static async getEntryCode(req: Request, res: Response) {
        try {
            const data = await settingsService.getEntryCode();
            successResponse(res, { entryCode: data || "1234" });
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to get entry code");
        }
    }

    static async updateEntryCode(req: Request, res: Response) {
        try {
            const { entryCode } = req.body;
            if (!entryCode) return errorResponse(res, "Entry code is required", 400);

            const updated = await settingsService.updateEntryCode(entryCode);
            successResponse(res, { entryCode: updated }, "Entry code updated successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to update entry code");
        }
    }

    // -------------------------------------------------------------------------
    // 사용자 앱 URL (User App URL)
    // -------------------------------------------------------------------------

    static async getUserAppUrl(req: Request, res: Response) {
        try {
            const data = await settingsService.getUserAppUrl();
            successResponse(res, { url: data });
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to get user app url");
        }
    }

    static async updateUserAppUrl(req: Request, res: Response) {
        try {
            const { url } = req.body;
            if (!url) return errorResponse(res, "URL is required", 400);

            const updated = await settingsService.updateUserAppUrl(url);
            successResponse(res, { url: updated }, "User app url updated successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to update user app url");
        }
    }

    // -------------------------------------------------------------------------
    // 사용자 알림 정보 (Notification)
    // -------------------------------------------------------------------------

    static async getUserNotification(req: Request, res: Response) {
        try {
            const data = await settingsService.getUserNotification();
            successResponse(res, { notification: data || "" });
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to get user notification");
        }
    }

    static async updateUserNotification(req: Request, res: Response) {
        try {
            const { notification } = req.body;
            if (notification === undefined) return errorResponse(res, "Notification message is required", 400);

            const updated = await settingsService.updateUserNotification(notification);
            successResponse(res, { notification: updated }, "User notification updated successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to update user notification");
        }
    }
}
