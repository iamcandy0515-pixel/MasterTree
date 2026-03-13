import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";
import fs from "fs";

const auth = googleDriveAuthService.getAuthClient();
const drive = google.drive({ version: "v3", auth });

async function listAll() {
    const folderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC";
    const response = await drive.files.list({
        q: `'${folderId}' in parents and trashed = false`,
        fields: "files(id, name)",
        pageSize: 100,
    });

    const names = response.data.files?.map((f) => f.name).join("\n") || "None";
    fs.writeFileSync("quiz_filenames.txt", names);
    console.log("Filenames saved to quiz_filenames.txt");
}

listAll().catch(console.error);
