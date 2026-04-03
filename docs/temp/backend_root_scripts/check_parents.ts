import dotenv from "dotenv";
dotenv.config();
import { GoogleDriveService } from "./src/modules/external/google_drive.service";

async function checkParents() {
  const driveService = new GoogleDriveService();
  
  try {
    const response = await driveService.drive.files.get({
      fileId: "1oEPEt_ERmNWrmm0gcSnM8aWxYc3jdKST", // 위에서 찾은 파일 중 하나
      fields: "id, name, parents"
    });

    console.log("File metadata with parents:");
    console.log(JSON.stringify(response.data, null, 2));
  } catch (error: any) {
    console.error("Failed to check parents:", error.message);
  }
}

checkParents();
