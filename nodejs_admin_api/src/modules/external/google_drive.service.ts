import { googleDriveFileService } from "./google_drive_file.service";

/**
 * Legacy interface for Google Drive operations.
 * Now routes calls to GoogleDriveFileService while maintaining compatibility.
 */
export class GoogleDriveService {
    /**
     * Search for an image in the specified Google Drive folder.
     */
    async searchImage(
        treeName: string,
        imageType: string,
        folderId: string,
    ): Promise<string | null> {
        try {
            if (!folderId) return null;

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
            const query = `'${folderId}' in parents and name contains '${searchTerm}' and mimeType contains 'image/' and trashed = false`;

            console.log(`🔍 [Drive] Searching: "${searchTerm}" in folder: ${folderId}`);

            const response = await googleDriveFileService.searchImages(query);
            const files = response.data.files;

            if (files && files.length > 0) {
                return `https://drive.google.com/uc?export=view&id=${files[0].id}`;
            }
            return null;
        } catch (error) {
            console.error("Error searching Google Drive:", error);
            throw error;
        }
    }

    /**
     * Search for files by keyword in a folder.
     */
    async searchFilesInFolder(folderId: string, keyword: string) {
        const query = `'${folderId}' in parents and name contains '${keyword}' and trashed = false`;
        const response = await googleDriveFileService.searchFiles(query);
        return response.data.files || [];
    }

    /**
     * Download a file as Buffer.
     */
    async downloadFileAsBuffer(fileId: string): Promise<Buffer> {
        return await googleDriveFileService.downloadFile(fileId);
    }

    /**
     * Search and download image buffer.
     */
    async searchAndDownloadImage(
        treeName: string,
        imageType: string,
        folderId: string,
    ): Promise<Buffer | null> {
        const url = await this.searchImage(treeName, imageType, folderId);
        if (url) {
            const fileId = url.split("id=")[1];
            if (fileId) {
                return this.downloadFileAsBuffer(fileId);
            }
        }
        return null;
    }

    // Expose drive for legacy scripts that access it directly
    get drive() {
        return googleDriveFileService.getDrive();
    }
}
