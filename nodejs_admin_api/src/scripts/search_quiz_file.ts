import { google } from "googleapis";
import path from "path";

const keyPath =
    "d:/MasterTreeApp/tree_app_monorepo/nodejs_admin_api/src/config/service-account.json";

const auth = new google.auth.GoogleAuth({
    keyFile: keyPath,
    scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

const drive = google.drive({ version: "v3", auth });

async function searchFile() {
    const fileName = "산림필답_2022_2";
    const response = await drive.files.list({
        q: `name contains '${fileName}' and trashed = false`,
        fields: "files(id, name, parents)",
    });

    console.log(`Searching for '${fileName}':`);
    if (!response.data.files || response.data.files.length === 0) {
        console.log("NOT FOUND globally for this service account.");
    } else {
        response.data.files.forEach((f) => {
            console.log(
                `- FOUND: ${f.name} (ID: ${f.id}, Parent: ${f.parents ? f.parents[0] : "None"})`,
            );
        });
    }
}

searchFile().catch(console.error);
