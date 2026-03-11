import { google } from "googleapis";
import { googleDriveAuthService } from "./google_drive_auth.service";

/**
 * Service to handle Google Drive file operations (search, download, upload).
 */
export class GoogleDriveFileService {
    private drive;

    constructor() {
        const auth = googleDriveAuthService.getAuthClient();
        if (auth) {
            this.drive = google.drive({ version: "v3", auth });
        } else {
            // Fallback to API Key if OAuth2 is not configured
            const API_KEY = process.env.GOOGLE_DRIVE_API_KEY || process.env.GEMINI_KEY;
            this.drive = google.drive({ version: "v3", auth: API_KEY });
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
     * Download a file by ID using authenticated access or public link fallback.
     */
    async downloadFile(fileId: string): Promise<Buffer> {
        const axios = require("axios");
        
        try {
            // If OAuth2 is available, we can use the API directly or authenticated direct link
            const auth = googleDriveAuthService.getAuthClient();
            
            if (auth) {
                console.log(`⬇️ [Drive] Authenticated download for file: ${fileId}`);
                const response = await this.drive.files.get(
                    { fileId, alt: "media" },
                    { responseType: "arraybuffer" }
                );
                return Buffer.from(response.data as ArrayBuffer);
            }

            // Fallback for public files
            const verifiedUrl = `https://drive.google.com/uc?export=download&id=${fileId}`;
            const response = await axios.get(verifiedUrl, { responseType: "arraybuffer" });
            return Buffer.from(response.data as ArrayBuffer);
        } catch (error: any) {
            console.error("❌ Error downloading file from Drive:", error.message);
            throw error;
        }
    }

    /**
     * Create a file (upload) in a specific folder.
     */
    async createFile(name: string, folderId: string, mimeType: string, body: any) {
        if (!googleDriveAuthService.isConfigured()) {
            throw new Error("❌ OAuth2 must be configured to upload files.");
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
