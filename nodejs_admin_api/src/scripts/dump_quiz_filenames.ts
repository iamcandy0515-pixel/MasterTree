import { google } from "googleapis";
import path from "path";
import fs from "fs";

const keyPath =
    "d:/MasterTreeApp/tree_app_monorepo/nodejs_admin_api/src/config/service-account.json";

const auth = new google.auth.GoogleAuth({
    keyFile: keyPath,
    scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

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
