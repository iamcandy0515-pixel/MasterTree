import dotenv from "dotenv";
dotenv.config();
import { google } from "googleapis";
import { googleDriveAuthService } from "./src/modules/external/google_drive_auth.service";

async function deepSearch() {
  const auth = googleDriveAuthService.getAuthClient();
  const folderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC";
  
  try {
    const drive = google.drive({ version: "v3", auth });
    
    // 1. 단순 list 조회 (모든 옵션 포함)
    const res1 = await drive.files.list({
      q: `'${folderId}' in parents and trashed = false`,
      fields: "files(id, name)",
      supportsAllDrives: true,
      includeItemsFromAllDrives: true,
    });
    console.log("Result 1 (By Parent):", res1.data.files?.length, "files");

    // 2. 파일명으로 직접 조회 (부분 일치)
    const res2 = await drive.files.list({
      q: `name contains '산림필답' and trashed = false`,
      fields: "files(id, name, parents)",
      supportsAllDrives: true,
      includeItemsFromAllDrives: true,
    });
    console.log("Result 2 (By Keyword '산림필답'):", res2.data.files?.length, "files");
    if (res2.data.files && res2.data.files.length > 0) {
      res2.data.files.forEach(f => console.log(`- ${f.name} (Parent: ${f.parents})`));
    }

  } catch (error: any) {
    console.error("❌ Deep Search Failed:", error.message);
  }
}

deepSearch();
