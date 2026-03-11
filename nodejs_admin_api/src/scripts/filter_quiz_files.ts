import { google } from "googleapis";
import path from "path";

const keyPath =
    "d:/MasterTreeApp/tree_app_monorepo/nodejs_admin_api/src/config/service-account.json";

const auth = new google.auth.GoogleAuth({
    keyFile: keyPath,
    scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

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
