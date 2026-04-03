import dotenv from "dotenv";
dotenv.config();
import { google } from "googleapis";
import { googleDriveAuthService } from "./src/modules/external/google_drive_auth.service";

async function getDriveUserEmail() {
  const auth = googleDriveAuthService.getAuthClient();
  
  if (!auth) {
    console.error("❌ OAuth2 설정 누락");
    return;
  }

  try {
    const drive = google.drive({ version: "v3", auth });
    // 드라이브의 사용자 정보를 직접 요청 (drive scope만 있어도 가능)
    const response = await drive.about.get({
      fields: "user(emailAddress)"
    });
    
    console.log("\n========================================");
    console.log("✅ 인증된 드라이브 계정 이메일 확인");
    console.log(`📧 이메일: ${response.data.user?.emailAddress}`);
    console.log("========================================\n");
  } catch (error: any) {
    console.error("❌ 이메일 조회 실패:", error.message);
  }
}

getDriveUserEmail();
