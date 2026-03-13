import dotenv from "dotenv";
dotenv.config();
import { GoogleDriveService } from "./src/modules/external/google_drive.service";

async function testToken() {
  const driveService = new GoogleDriveService();
  
  try {
    const response = await driveService.drive.files.list({
      pageSize: 5,
      fields: "files(id, name)"
    });

    console.log("Root files found with current token:");
    console.log(JSON.stringify(response.data.files, null, 2));
  } catch (error: any) {
    console.error("Token test failed:", error.message);
  }
}

testToken();
