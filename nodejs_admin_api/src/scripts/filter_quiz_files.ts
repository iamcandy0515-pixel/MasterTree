import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";

const auth = googleDriveAuthService.getAuthClient();
const drive = google.drive({ version: "v3", auth });

async function filterFiles() {
    const folderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC";
    const response = await drive.files.list({
        q: `'${folderId}' in parents and name contains '2022' and trashed = false`,
        fields: "files(id, name)",
    });

    console.log("--- QUIZ FOLDER (2022 FILES) ---");
    if (!response.data.files || response.data.files.length === 0) {
        console.log("No files matching 2022.");
    } else {
        response.data.files.forEach((f) => {
            console.log(`- ${f.name} (${f.id})`);
        });
    }
}

filterFiles().catch(console.error);
