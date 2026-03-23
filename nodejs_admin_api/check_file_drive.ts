import dotenv from "dotenv";
dotenv.config();
import { googleDriveFileService } from "./src/modules/external/google_drive_file.service";

async function checkFile() {
    const fileId = "1btu8LATOCjwLqhdFvtVBAbbMOKlpkoQW";
    try {
        const response = await googleDriveFileService.getDrive().files.get({
            fileId: fileId,
            fields: "id, name, parents"
        });
        console.log("File Info:", JSON.stringify(response.data, null, 2));
    } catch (e: any) {
        console.error("Error:", e.message);
    }
}

checkFile();
