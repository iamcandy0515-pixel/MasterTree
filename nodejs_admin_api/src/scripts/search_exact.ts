import { google } from "googleapis";
import path from "path";

const keyPath =
    "d:/MasterTreeApp/tree_app_monorepo/nodejs_admin_api/src/config/service-account.json";

const auth = new google.auth.GoogleAuth({
    keyFile: keyPath,
    scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

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
