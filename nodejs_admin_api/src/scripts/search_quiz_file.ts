import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";

async function searchFile() {
    const auth = googleDriveAuthService.getAuthClient();
    if (!auth) {
        console.error("❌ Google Auth not configured in .env");
        return;
    }

    const drive = google.drive({ version: "v3", auth });
    const fileName = "산림필답_2022_2";
    
    const response = await drive.files.list({
        q: `name contains '${fileName}' and trashed = false`,
        fields: "files(id, name, parents)",
    });

    console.log(`Searching for '${fileName}':`);
    if (!response.data.files || response.data.files.length === 0) {
        console.log("NOT FOUND globally for current credentials.");
    } else {
        response.data.files.forEach((f) => {
            console.log(
                `- FOUND: ${f.name} (ID: ${f.id}, Parent: ${f.parents ? f.parents[0] : "None"})`,
            );
        });
    }
}

searchFile().catch(console.error);
