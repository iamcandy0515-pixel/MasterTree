import dotenv from "dotenv";
dotenv.config();
import { googleDriveFileService } from "./src/modules/external/google_drive_file.service";

async function listFiles() {
    const folderId = "1GK_EJ3ZaJ8nzdH1JW7wD_bXn6RH6BxkT";
    const query = `'${folderId}' in parents and trashed = false`;
    
    console.log(`Listing files in folder: ${folderId}`);
    try {
        const response = await googleDriveFileService.searchFiles(query);
        const files = response.data.files || [];
        console.log(`Total files found: ${files.length}`);
        files.forEach(f => {
            console.log(`- ${f.name} (${f.id})`);
        });
    } catch (e) {
        console.error("Error listing files:", e);
    }
}

listFiles();
