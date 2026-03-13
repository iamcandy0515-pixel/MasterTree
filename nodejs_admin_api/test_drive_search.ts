import dotenv from "dotenv";
dotenv.config();
import { GoogleDriveService } from "./src/modules/external/google_drive.service";
import { settingsService } from "./src/modules/settings/settings.service";
import { extractDriveFolderId } from "./src/utils/drive-helper";

async function testSearch() {
  const folderUrl = await settingsService.getExamDriveUrl();
  console.log("Folder URL:", folderUrl);
  
  const folderId = extractDriveFolderId(folderUrl);
  console.log("Extracted Folder ID:", folderId);

  if (!folderId) {
    console.error("Failed to extract folder ID");
    return;
  }

  const driveService = new GoogleDriveService();
  
  // 기출문제 폴더의 파일 목록을 일부 가져와봅니다.
  const response = await driveService.drive.files.list({
    q: `'${folderId}' in parents and trashed = false`,
    fields: "files(id, name)",
    pageSize: 5
  });

  console.log("Files in folder:");
  console.log(JSON.stringify(response.data.files, null, 2));

  // 검색 테스트 (목록 중 첫번째 파일명으로 시도)
  if (response.data.files && response.data.files.length > 0) {
    const testName = response.data.files[0].name;
    console.log(`\nTesting search with name: "${testName}"`);
    const searchResult = await driveService.searchFilesInFolder(folderId, testName);
    console.log("Search Result Count:", searchResult.length);
    console.log("Found File ID:", searchResult[0]?.id);
  } else {
    console.log("No files found in the folder to test search.");
  }
}

testSearch();
