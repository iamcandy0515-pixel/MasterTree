import dotenv from "dotenv";
dotenv.config();
import { googleDriveFileService } from "./src/modules/external/google_drive_file.service";

async function globalSearch() {
    console.log("Starting global search script...");
    const query = `mimeType contains 'image/' and trashed = false`;
    
    try {
        console.log("Calling drive.files.list...");
        const response = await googleDriveFileService.searchFiles(query);
        console.log("Response received.");
        const files = response.data.files || [];
        console.log(`Total images found: ${files.length}`);
        files.slice(0, 5).forEach(f => {
            console.log(`- ${f.name} (${f.id})`);
        });
    } catch (e: any) {
        console.error("Error global searching:", e.message);
        if (e.response) {
            console.error("Data:", e.response.data);
        }
    }
    console.log("Script finished.");
}

globalSearch();
