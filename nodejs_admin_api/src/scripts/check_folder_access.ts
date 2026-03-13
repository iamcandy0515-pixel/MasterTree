import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";

const auth = googleDriveAuthService.getAuthClient();
const drive = google.drive({ version: "v3", auth });

async function checkFolder() {
    const folderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC";
    try {
        const response = await drive.files.get({
            fileId: folderId,
            fields: "id, name, mimeType",
        });
        console.log(
            `Folder found: ${response.data.name} (ID: ${response.data.id})`,
        );
    } catch (error: any) {
        console.log(`Folder NOT ACCESSIBLE: ${folderId}`);
        console.log(`Error: ${error.message}`);
    }
}

checkFolder().catch(console.error);
