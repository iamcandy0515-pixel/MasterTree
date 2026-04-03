import { supabase } from "../../config/supabaseClient";
import { logger } from "../../utils/logger";

export class SettingsDriveService {
    // Get Google Drive folder URL (Original Images)
    async getGoogleDriveFolderUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .in("key", ["google_drive_folder_url", "tree_image_drive_url"]) // Fallback keys
            .order('updated_at', { ascending: false })
            .limit(1);

        if (error || !data || data.length === 0) {
            return "";
        }
        return data[0].value;
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

    // Get Thumbnail Drive URL
    async getThumbnailDriveUrl() {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .in("key", ["thumbnail_drive_url", "tree_thumbnail_drive_url"])
            .order('updated_at', { ascending: false })
            .limit(1);

        if (error || !data || data.length === 0) {
            return "";
        }
        return data[0].value;
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

    // Get Exam Drive URL
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

    // Update Exam Drive URL
    async updateExamDriveUrl(url: string) {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key: "exam_drive_url",
                    value: url,
                    description: "구글 드라이브 기출문제 폴더 URL",
                    updated_at: new Date().toISOString(),
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

export const settingsDriveService = new SettingsDriveService();
