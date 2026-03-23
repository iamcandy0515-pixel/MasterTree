import { extractDriveFolderId } from "../../../utils/drive-helper";
import { settingsService } from "../../settings/settings.service";

/**
 * Common helpers for external Google Drive and Image modules.
 */
export class ExternalHelperService {
    /**
     * Get and validate folder ID from settings.
     */
    async getFolderIdFromSettings(type: "original" | "thumbnail" = "original"): Promise<string | null> {
        const folderUrl = type === "original"
            ? await settingsService.getGoogleDriveFolderUrl()
            : await settingsService.getThumbnailDriveUrl();
        
        return folderUrl ? extractDriveFolderId(folderUrl) : null;
    }

    /**
     * Map image types to Korean names for file naming.
     */
    getTypeMap(): Record<string, string> {
        return {
            main: "대표",
            flower: "꽃",
            fruit: "열매",
            bark: "수피",
            leaf: "잎",
        };
    }

    /**
     * Extract specific file ID from Drive URL for existence checks.
     */
    getFileId(u: string): string | null {
        if (u.includes("id=")) return u.split("id=")[1].split("&")[0];
        const parts = u.split("/");
        return parts[parts.length - 1] || null;
    }
}

export const externalHelperService = new ExternalHelperService();
