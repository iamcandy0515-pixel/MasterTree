import { google } from "googleapis";
import { googleDriveAuthService } from "./google_drive_auth.service";

/**
 * Service to handle Google Drive file operations.
 * Enforces authenticated access using Service Account or ADC.
 */
export class GoogleDriveFileService {
    private drive;

    constructor() {
        const auth = googleDriveAuthService.getAuthClient();
        if (auth) {
            this.drive = google.drive({ version: "v3", auth });
        } else {
            console.error("❌ [Drive File Service] Critical Error: Authentication not initialized.");
            // We still initialize with null auth to prevent immediate crashes, but calls will fail
            this.drive = google.drive({ version: "v3" });
        }
    }

    /**
     * Get the drive instance.
     */
    getDrive() {
        return this.drive;
    }

    /**
     * Search for images in a folder.
     */
    async searchImages(query: string) {
        if (!googleDriveAuthService.isConfigured()) {
            throw new Error("❌ Authentication required for file operations.");
        }
        return await this.drive.files.list({
            q: query,
            fields: "files(id, name, mimeType)",
            pageSize: 10,
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
        });
    }

    /**
     * Search for files in a folder with specific fields.
     */
    async searchFiles(query: string) {
        if (!googleDriveAuthService.isConfigured()) {
            throw new Error("❌ Authentication required for file operations.");
        }
        return await this.drive.files.list({
            q: query,
            fields: "files(id, name, mimeType, webContentLink, createdTime, size, iconLink)",
            pageSize: 20,
            orderBy: "createdTime desc",
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
        });
    }

    /**
     * Download a file by ID using authenticated access.
     * Public link fallback removed for security.
     */
    async downloadFile(fileId: string): Promise<Buffer> {
        try {
            if (!googleDriveAuthService.isConfigured()) {
                throw new Error("❌ Authentication required to download files.");
            }

            console.log(`⬇️ [Drive] Authenticated download for file: ${fileId}`);
            const response = await this.drive.files.get(
                { fileId, alt: "media" },
                { responseType: "arraybuffer" }
            );
            return Buffer.from(response.data as ArrayBuffer);
        } catch (error: any) {
            console.error(`❌ Error downloading file ${fileId} from Drive:`, error.message);
            throw error;
        }
    }

    /**
     * Create a file (upload) in a specific folder.
     */
    async createFile(name: string, folderId: string, mimeType: string, body: any) {
        if (!googleDriveAuthService.isConfigured()) {
            throw new Error("❌ Authentication required to upload files.");
        }

        return await this.drive.files.create({
            requestBody: {
                name,
                parents: [folderId],
            },
            media: {
                mimeType,
                body,
            },
            fields: "id",
        });
    }
}

export const googleDriveFileService = new GoogleDriveFileService();
