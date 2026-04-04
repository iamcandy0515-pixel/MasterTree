import dotenv from "dotenv";
dotenv.config();
import { GoogleDriveService } from "./src/modules/external/google_drive.service";

async function listAllFiles() {
  const folderId = "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC"; // 기출문제 폴더 ID
  const driveService = new GoogleDriveService();
  
  try {
    console.log(`📂 폴더 ID [${folderId}] 내의 모든 파일을 조회합니다...`);
    
    const response = await driveService.drive.files.list({
      q: `'${folderId}' in parents and trashed = false`,
      fields: "files(id, name, mimeType)",
      supportsAllDrives: true,
      includeItemsFromAllDrives: true,
    });

    const files = response.data.files || [];
    console.log(`✅ 조회된 파일 수: ${files.length}개`);
    
    files.forEach((file, index) => {
      console.log(`[${index + 1}] 명: ${file.name} | ID: ${file.id} | 유형: ${file.mimeType}`);
    });

    if (files.length === 0) {
      console.log("⚠️ 폴더가 비어있거나 접근 권한이 없습니다.");
    }
  } catch (error: any) {
    console.error("❌ 드라이브 조회 중 오류 발생:", error.message);
  }
}

listAllFiles();
