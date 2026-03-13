import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";

const auth = googleDriveAuthService.getAuthClient();
const drive = google.drive({ version: "v3", auth });

async function testSearch() {
    const folderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC";
    const keyword = "산림필답_2022_2";

    const query = `'${folderId}' in parents and name contains '${keyword}' and trashed = false`;
    console.log(`Query: ${query}`);

    const response = await drive.files.list({
        q: query,
        fields: "files(id, name)",
    });

    console.log(`Found: ${response.data.files?.length || 0}`);
    response.data.files?.forEach((f) => console.log(`- ${f.name} (${f.id})`));
}

testSearch().catch(console.error);
