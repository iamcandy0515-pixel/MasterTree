import { supabase } from "../../config/supabaseClient";
import { logger } from "../../utils/logger";

export class SettingsService {
    // -------------------------------------------------------------------------
    // 기초 설정 (Entry Code, User App URL)
    // -------------------------------------------------------------------------

    // Get entry code
    async getEntryCode() {
        // Fetch from 'app_settings' table where key = 'entry_code'
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "entry_code")
            .single();

        if (error) {
            if (error.code === "PGRST116") {
                logger.warn("Entry code not found, returning default '1234'");
                return "1234";
            }
            throw error;
        }
        return data.value;
    }

    // Update entry code
    async updateEntryCode(code: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "entry_code",
                    value: code,
                    description: "앱 입장 코드",
                    updated_at: new Date().toISOString(),
                },
                { onConflict: "key" },
            )
            .select()
            .single();

        if (error) {
            logger.error("Failed to update entry code", error);
            throw error;
        }
        return data.value;
    }

    // Get user app url
    async getUserAppUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "user_app_url")
            .single();

        if (error) {
            if (error.code === "PGRST116") return "http://localhost:8080";
            throw error;
        }
        return data.value;
    }

    // Update user app url
    async updateUserAppUrl(url: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "user_app_url",
                    value: url,
                    description: "사용자 앱 URL (QR생성용)",
                    updated_at: new Date().toISOString(),
                },
                { onConflict: "key" },
            )
            .select()
            .single();

        if (error) {
            logger.error("Failed to update user app url", error);
            throw error;
        }
        return data.value;
    }

    // -------------------------------------------------------------------------
    // 구글 드라이브 및 외부 저장소 URL (Drive, Thumbnails, Exams)
    // -------------------------------------------------------------------------

    // Get google drive folder url
    async getGoogleDriveFolderUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "google_drive_folder_url")
            .single();

        if (error) {
            if (error.code === "PGRST116") return "";
            throw error;
        }
        return data.value;
    }

    // Update google drive folder url
    async updateGoogleDriveFolderUrl(url: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "google_drive_folder_url",
                    value: url,
                    description: "구글 드라이브 원본 폴더 URL",
                    updated_at: new Date().toISOString(),
                },
                { onConflict: "key" },
            )
            .select()
            .single();

        if (error) {
            logger.error("Failed to update google drive folder url", error);
            throw error;
        }
        return data.value;
    }

    // Get thumbnail drive url
    async getThumbnailDriveUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "thumbnail_drive_url")
            .single();

        if (error) {
            if (error.code === "PGRST116") return "";
            throw error;
        }
        return data.value;
    }

    // Update thumbnail drive url
    async updateThumbnailDriveUrl(url: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "thumbnail_drive_url",
                    value: url,
                    description: "구글 드라이브 썸네일 폴더 URL",
                    updated_at: new Date().toISOString(),
                },
                { onConflict: "key" },
            )
            .select()
            .single();

        if (error) {
            logger.error("Failed to update thumbnail drive url", error);
            throw error;
        }
        return data.value;
    }

    // Get exam drive url
    async getExamDriveUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "exam_drive_url")
            .single();

        if (error) {
            if (error.code === "PGRST116") return "";
            throw error;
        }
        return data.value;
    }

    // -------------------------------------------------------------------------
    // 사용자 알림 정보 (Notification)
    // -------------------------------------------------------------------------

    // Get notification message
    async getUserNotification() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "user_notification")
            .single();

        if (error) {
            if (error.code === "PGRST116") {
                return ""; // 없을 시 기본값 empty string
            }
            throw error;
        }
        return data.value;
    }

    // Update notification message
    async updateUserNotification(message: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "user_notification",
                    value: message,
                    description: "사용자 앱 공지/알림 정보",
                    updated_at: new Date().toISOString(),
                },
                { onConflict: "key" },
            )
            .select()
            .single();

        if (error) {
            logger.error("Failed to update user notification", error);
            throw error;
        }
        return data.value;
    }
}

export const settingsService = new SettingsService();
