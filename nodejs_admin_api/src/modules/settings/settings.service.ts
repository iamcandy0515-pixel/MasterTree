import { settingsRepository } from "./settings.repository";

export class SettingsService {
    /**
     * Adheres strictly to DEVELOPMENT_RULES.md (Rule 1-1, < 200 lines).
     * Business logic for application settings.
     */

    async getEntryCode() {
        return (await settingsRepository.getValue("entry_code")) || "1133";
    }

    async updateEntryCode(code: string) {
        return await settingsRepository.upsertValue("entry_code", code, "앱 입장 코드");
    }

    async resetAllUserEntryCodes() {
        const currentCode = await this.getEntryCode();
        return await settingsRepository.updateAllUsersEntryCode(currentCode);
    }

    async getUserAppUrl() {
        return (await settingsRepository.getValue("user_app_url")) || "http://localhost:8080";
    }

    async updateUserAppUrl(url: string) {
        return await settingsRepository.upsertValue("user_app_url", url, "사용자 앱 URL (QR생성용)");
    }

    async getGoogleDriveFolderUrl() {
        return (await settingsRepository.getMultipleValues(["google_drive_folder_url", "tree_image_drive_url"])) || "";
    }

    async updateGoogleDriveFolderUrl(url: string) {
        return await settingsRepository.upsertValue("google_drive_folder_url", url, "구글 드라이브 폴더 URL (문제 추출용)");
    }

    async getThumbnailDriveUrl() {
        return (await settingsRepository.getMultipleValues(["thumbnail_drive_url", "tree_thumbnail_drive_url"])) || "";
    }

    async updateThumbnailDriveUrl(url: string) {
        return await settingsRepository.upsertValue("thumbnail_drive_url", url, "구글 드라이브 썸네일 폴더 URL");
    }

    async getExamDriveUrl() {
        return (await settingsRepository.getValue("exam_drive_url")) || "";
    }

    async updateExamDriveUrl(url: string) {
        return await settingsRepository.upsertValue("exam_drive_url", url, "구글 드라이브 기출문제 폴더 URL");
    }

    async getNotice() {
        return (await settingsRepository.getValue("user_notice")) || "";
    }

    async updateNotice(notice: string) {
        return await settingsRepository.upsertValue("user_notice", notice, "사용자 앱 공지사항 안내문");
    }
}

export const settingsService = new SettingsService();
