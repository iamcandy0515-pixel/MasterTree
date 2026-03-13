import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";

const auth = googleDriveAuthService.getAuthClient();
const drive = google.drive({ version: "v3", auth });

async function listAllFiles() {
    const response = await drive.files.list({
        pageSize: 10,
        fields: "files(id, name, parents)",
    });

    console.log("Top 10 files visible to service account:");
    if (!response.data.files || response.data.files.length === 0) {
        console.log("No files visible.");
    } else {
        response.data.files.forEach((f) => {
            console.log(
                `- ${f.name} (ID: ${f.id}, Parent: ${f.parents ? f.parents[0] : "None"})`,
            );
        });
    }
}

listAllFiles().catch(console.error);
