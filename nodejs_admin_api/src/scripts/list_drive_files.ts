import { google } from "googleapis";
import path from "path";

const keyPath =
    "d:/MasterTreeApp/tree_app_monorepo/nodejs_admin_api/src/config/service-account.json";

const auth = new google.auth.GoogleAuth({
    keyFile: keyPath,
    scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

const drive = google.drive({ version: "v3", auth });

async function listFiles() {
    const folderId = "1GK_EJ3ZaJ8nzdH1JW7wD_bXn6RH6BxkT";
    const response = await drive.files.list({
        q: `'${folderId}' in parents and trashed = false`,
        fields: "files(id, name)",
    });

    console.log("Files in folder:");
    if (!response.data.files || response.data.files.length === 0) {
        console.log("Empty folder.");
    } else {
        response.data.files.forEach((f) =>
            console.log(`- ${f.name} (${f.id})`),
        );
    }
}

listFiles().catch(console.error);
