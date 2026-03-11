import { google } from "googleapis";
import path from "path";

const keyPath =
    "d:/MasterTreeApp/tree_app_monorepo/nodejs_admin_api/src/config/service-account.json";

const auth = new google.auth.GoogleAuth({
    keyFile: keyPath,
    scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

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
