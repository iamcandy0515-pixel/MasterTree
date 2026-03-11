import { supabase } from "../../config/supabaseClient";
import { logger } from "../../utils/logger";

export class SettingsService {
    // Get entry code
    async getEntryCode() {
        // Fetch from 'app_settings' table where key = 'entry_code'
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "entry_code")
            .single();

        if (error) {
            // If doesn't exist, return default or create one?
            if (error.code === "PGRST116") {
                // Not found, return null or default
                logger.warn("Entry code not found, returning default '1234'");
                return "1234";
            }
            throw error;
        }

        return data.value;
    }

    // Update entry code
    async updateEntryCode(code: string) {
        // Upsert entry code
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "entry_code",
                    value: code,
                    description: "앱 입장 코드",
                    updated_at: new Date(),
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
            if (error.code === "PGRST116") {
                // Not found, return default dev url
                return "http://localhost:8080";
            }
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
                    updated_at: new Date(),
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

    // Get Google Drive folder URL
    async getGoogleDriveFolderUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "google_drive_folder_url")
            .single();

        if (error) {
            if (error.code === "PGRST116") {
                return "";
            }
            throw error;
        }

        return data.value;
    }

    // Update Google Drive folder URL
    async updateGoogleDriveFolderUrl(url: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "google_drive_folder_url",
                    value: url,
                    description: "구글 드라이브 폴더 URL (문제 추출용)",
                    updated_at: new Date(),
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

    // Get Thumbnail Drive URL
    async getThumbnailDriveUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "thumbnail_drive_url")
            .single();

        if (error) {
            if (error.code === "PGRST116") {
                return "";
            }
            throw error;
        }

        return data.value;
    }

    // Update Thumbnail Drive URL
    async updateThumbnailDriveUrl(url: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "thumbnail_drive_url",
                    value: url,
                    description: "구글 드라이브 썸네일 폴더 URL",
                    updated_at: new Date(),
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
    // Get Exam Drive URL
    async getExamDriveUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", "exam_drive_url")
            .single();

        if (error) {
            if (error.code === "PGRST116") {
                return "";
            }
            throw error;
        }

        return data.value;
    }

    // Update Exam Drive URL
    async updateExamDriveUrl(url: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "exam_drive_url",
                    value: url,
                    description: "구글 드라이브 기출문제 폴더 URL",
                    updated_at: new Date(),
                },
                { onConflict: "key" },
            )
            .select()
            .single();

        if (error) {
            logger.error("Failed to update exam drive url", error);
            throw error;
        }

        return data.value;
    }
}

export const settingsService = new SettingsService();
