import { google } from "googleapis";
import path from "path";

const keyPath =
    "d:/MasterTreeApp/tree_app_monorepo/nodejs_admin_api/src/config/service-account.json";

const auth = new google.auth.GoogleAuth({
    keyFile: keyPath,
    scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

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
