import { google } from "googleapis";
import path from "path";

const keyPath =
    "d:/MasterTreeApp/tree_app_monorepo/nodejs_admin_api/src/config/service-account.json";

const auth = new google.auth.GoogleAuth({
    keyFile: keyPath,
    scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

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
