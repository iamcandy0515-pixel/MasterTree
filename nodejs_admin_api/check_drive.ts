import { GoogleDriveService } from "./src/modules/external/google_drive.service";
import { settingsService } from "./src/modules/settings/settings.service";
import { extractDriveFolderId } from "./src/utils/drive-helper";

async function check() {
    try {
        const folderUrl = (await settingsService.getExamDriveUrl()) || (await settingsService.getGoogleDriveFolderUrl());
        console.log("Folder URL:", folderUrl);
        const folderId = extractDriveFolderId(folderUrl);
        console.log("Folder ID:", folderId);

        const driveService = new GoogleDriveService();
        // check with literal '산림'
        const files = await driveService.searchFilesInFolder(folderId, '산림');
        console.log("Files found with '산림':", files.map(f => f.name));
        
        // check with literal '2013'
        const files2 = await driveService.searchFilesInFolder(folderId, '2013');
        console.log("Files found with '2013':", files2.map(f => f.name));
        
    } catch(e) {
        console.error(e);
    }
}
check();
