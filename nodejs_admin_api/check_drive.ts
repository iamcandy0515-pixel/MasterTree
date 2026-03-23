import { googleDriveAuthService } from "./src/modules/external/google_drive_auth.service";
import { googleDriveFileService } from "./src/modules/external/google_drive_file.service";
import * as dotenv from 'dotenv';
dotenv.config();

async function checkDriveHealth() {
  console.log('--- Google Drive Health Check ---');
  console.log('Is Configured:', googleDriveAuthService.isConfigured());
  
  try {
    const drive = googleDriveFileService.getDrive();
    const response = await drive.files.list({ pageSize: 1 });
    console.log('✅ Drive API connected successfully.');
    console.log('Found files:', response.data.files?.length);
  } catch (e: any) {
    console.error('❌ Drive API connection failed:', e.message);
  }
}

checkDriveHealth();
