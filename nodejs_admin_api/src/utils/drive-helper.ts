/**
 * Utility to extract Google Drive Folder ID from various URL patterns.
 * Supported patterns:
 * - https://drive.google.com/drive/folders/ID
 * - https://drive.google.com/open?id=ID
 * - https://drive.google.com/drive/u/0/folders/ID
 */
export const extractDriveFolderId = (url: string): string | null => {
    if (!url) return null;

    // Pattern 1: /folders/ID
    const foldersMatch = url.match(/\/folders\/([a-zA-Z0-9-_]+)/);
    if (foldersMatch && foldersMatch[1]) {
        return foldersMatch[1];
    }

    // Pattern 2: ?id=ID
    try {
        const urlObj = new URL(url);
        const idParam = urlObj.searchParams.get("id");
        if (idParam) return idParam;
    } catch (e) {
        // Not a valid URL, try fallback
    }

    // Fallback: If it's already just an ID (length check)
    const trimmed = url.trim();
    if (trimmed.length >= 25 && !trimmed.includes("/")) {
        return trimmed;
    }

    return null;
};
