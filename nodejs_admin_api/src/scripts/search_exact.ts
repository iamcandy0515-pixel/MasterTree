import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";

const auth = googleDriveAuthService.getAuthClient();
const drive = google.drive({ version: "v3", auth });

async function searchExact() {
    const folderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC";
    const names = [
        "산림필답_2022_1.pdf",
        "산림필답_2022_2.pdf",
        "산림필답_2022_3.pdf",
    ];

    for (const name of names) {
        const response = await drive.files.list({
            q: `'${folderId}' in parents and name = '${name}' and trashed = false`,
            fields: "files(id, name)",
        });
        console.log(
            `Search for '${name}': ${response.data.files?.length || 0} found.`,
        );
    }
}

searchExact().catch(console.error);
