import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";

const auth = googleDriveAuthService.getAuthClient();
const drive = google.drive({ version: "v3", auth });

async function listFiles() {
    const folderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC";
    const response = await drive.files.list({
        q: `'${folderId}' in parents and trashed = false`,
        fields: "files(id, name)",
    });

    console.log(`Files in QUIZ folder (${folderId}):`);
    if (!response.data.files || response.data.files.length === 0) {
        console.log("Empty folder.");
    } else {
        response.data.files.forEach((f) =>
            console.log(`- ${f.name} (${f.id})`),
        );
    }
}

listFiles().catch(console.error);
