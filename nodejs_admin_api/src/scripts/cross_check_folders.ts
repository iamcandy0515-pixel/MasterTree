import { google } from "googleapis";
import { googleDriveAuthService } from "../modules/external/google_drive_auth.service";

const auth = googleDriveAuthService.getAuthClient();
const drive = google.drive({ version: "v3", auth });

async function checkFolders() {
    const quizFolderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC";
    const treeFolderId = "1GK_EJ3ZaJ8nzdH1JW7wD_bXn6RH6BxkT";

    const folders = [
        { id: quizFolderId, name: "QUIZ" },
        { id: treeFolderId, name: "TREE" },
    ];

    for (const f of folders) {
        const response = await drive.files.list({
            q: `'${f.id}' in parents and trashed = false`,
            fields: "files(id, name)",
        });
        console.log(`--- Folder: ${f.name} (${f.id}) ---`);
        if (!response.data.files || response.data.files.length === 0) {
            console.log("Empty");
        } else {
            response.data.files.forEach((file) => {
                if (file.name?.includes("산림")) {
                    console.log(`[FOUND!] ${file.name} (${file.id})`);
                }
            });
            console.log(`(Total ${response.data.files.length} files)`);
        }
    }
}

checkFolders().catch(console.error);
