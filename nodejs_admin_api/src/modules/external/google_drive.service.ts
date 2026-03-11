import { google } from "googleapis";
import dotenv from "dotenv";

dotenv.config();

const API_KEY = process.env.GOOGLE_DRIVE_API_KEY || process.env.GEMINI_KEY;

export class GoogleDriveService {
    private drive;

    constructor() {
        if (!API_KEY) {
            console.warn("⚠️ Google API Key is missing. Drive API might fail.");
        }
        this.drive = google.drive({
            version: "v3",
            auth: API_KEY,
        });
    }

    /**
     * Search for an image in the specified Google Drive folder based on tree name and image type.
     * Naming convention: "{TreeName}_{Type}" (e.g., "가시나무_대표")
     */
    async searchImage(
        treeName: string,
        imageType: string,
        folderId: string, // Accept dynamic folderId
    ): Promise<string | null> {
        try {
            if (!folderId) {
                console.warn("⚠️ Folder ID is missing for Drive search.");
                return null;
            }

            const typeMap: Record<string, string> = {
                main: "대표",
                representative: "대표",
                flower: "꽃",
                fruit: "열매",
                bark: "수피",
                leaf: "잎",
            };

            const koreanType = typeMap[imageType] || imageType;
            const searchTerm = `${treeName}_${koreanType}`;

            // Use the provided folderId
            const query = `'${folderId}' in parents and name contains '${searchTerm}' and mimeType contains 'image/' and trashed = false`;

            console.log(
                `🔍 [Drive] Searching: "${searchTerm}" in folder: ${folderId}`,
            );

            const response = await this.drive.files.list({
                q: query,
                fields: "files(id, name, mimeType)",
                pageSize: 10,
            });

            const files = response.data.files;
            console.log(`✅ [Drive] Found ${files?.length || 0} files.`);

            if (files && files.length > 0) {
                files.forEach((f, index) => {
                    console.log(
                        `   - File[${index}]: ${f.name} (${f.id}) [${f.mimeType}]`,
                    );
                });

                // Prioritize exact match if possible, but for now take the first one
                const file = files[0];
                // Use webContentLink for direct download/view or thumbnailLink for preview
                // thumbnailLink usually works better for simple display without auth issues in <img> tags sometimes
                // But often webContentLink is the actual file.
                // Let's return thumbnailLink for now as it is often publicly accessible if folder is public.
                // However, for high res, we might need a direct link format.

                // Construct a direct view link using ID (more reliable for public files)
                // Format: https://drive.google.com/uc?export=view&id={FILE_ID}
                return `https://drive.google.com/uc?export=view&id=${file.id}`;
            }

            return null;
        } catch (error: any) {
            console.error(
                "Error searching Google Drive full object:",
                JSON.stringify(error, null, 2),
            );
            if (error.response && error.response.status === 403) {
                console.error(
                    "⚠️ PERMISSION DENIED: Connect to Google Cloud Console and ENABLE 'Google Drive API' for this project/API Key.",
                );
            }
            throw error; // Re-throw to be handled by controller
        }
    }

    /**
     * Search for files (like PDF or Images) in a specific folder by keyword
     */
    async searchFilesInFolder(folderId: string, keyword: string) {
        try {
            const query = `'${folderId}' in parents and name contains '${keyword}' and trashed = false`;

            console.log(
                `🔍 [Drive] Searching files in folder: ${folderId} with keyword: '${keyword}'`,
            );

            const response = await this.drive.files.list({
                q: query,
                fields: "files(id, name, mimeType, webContentLink, createdTime, size, iconLink)",
                pageSize: 20,
                orderBy: "createdTime desc",
                supportsAllDrives: true,
                includeItemsFromAllDrives: true,
            });

            return response.data.files || [];
        } catch (error: any) {
            console.error(
                "Error searching files in folder:",
                JSON.stringify(error, null, 2),
            );
            throw error;
        }
    }

    async downloadFileAsBuffer(fileId: string): Promise<Buffer> {
        try {
            // Using Google Drive API's 'files.get' often fails with 403 when using only an API Key.
            // Instead, we use the direct download link which works for public files.
            const verifiedUrl = `https://drive.google.com/uc?export=download&id=${fileId}`;

            console.log(
                `⬇️ [Drive] Downloading via direct link: ${verifiedUrl}`,
            );

            // We need axios to perform the download
            // Dynamic import or require if axios is not imported at top level,
            // but it is in package.json. We should import it at the top of the file ideally.
            // For now, I'll use require to minimize diff, or better, add import at top if I can edit multiple chunks.
            // Since this is replace_file_content for a range, let's use require or assume import is present?
            // Checking file content again... axios is NOT imported in the original file.
            // So I will use require logic inside, or I should use multi_replace to add import.
            // Let's use require('axios') for safety in this block.
            const axios = require("axios");

            const response = await axios.get(verifiedUrl, {
                responseType: "arraybuffer",
            });

            return Buffer.from(response.data as ArrayBuffer);
        } catch (error: any) {
            console.error(
                "❌ Error downloading file from Drive direct link:",
                error.message,
            );
            // Fallback: Try the API method if direct link fails (unlikely for public files)
            try {
                console.log(
                    "⚠️ Direct link failed. Retrying with Drive API...",
                );
                const response = await this.drive.files.get(
                    { fileId, alt: "media" },
                    { responseType: "arraybuffer" },
                );
                return Buffer.from(response.data as ArrayBuffer);
            } catch (apiError: any) {
                console.error(
                    "❌ Drive API fallback also failed:",
                    apiError.message,
                );
                throw error;
            }
        }
    }

    async searchAndDownloadImage(
        treeName: string,
        imageType: string,
        folderId: string,
    ): Promise<Buffer | null> {
        const url = await this.searchImage(treeName, imageType, folderId);
        if (url) {
            // Extract File ID from URL
            // URL format: https://drive.google.com/uc?export=view&id={FILE_ID}
            const fileId = url.split("id=")[1];
            if (fileId) {
                return this.downloadFileAsBuffer(fileId);
            }
        }
        return null;
    }
}
