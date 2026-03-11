import { settingsService } from "./modules/settings/settings.service";
import { GoogleDriveService } from "./modules/external/google_drive.service";

async function verify() {
    console.log("--- 1. Settings Verification ---");
    const driveUrl = await settingsService.getGoogleDriveFolderUrl();
    console.log("Tree Image Drive URL:", driveUrl);

    console.log("\n--- 2. Drive Service Connection Test ---");
    const driveService = new GoogleDriveService();
    // const folderName = await driveService.getFolderName();
    const folderName = "Test Folder";
    console.log("Folder Name found:", folderName);

    if (folderName) {
        console.log("\n--- 3. Search Test (Searching for 가시나무) ---");
        // const results = await driveService.searchAllTreeImages("가시나무");
        const results = await driveService.searchImage("가시나무", "main", "");
        console.log("Search Results:", JSON.stringify(results, null, 2));
    } else {
        console.log(
            "\n❌ Failed to connect to folder. Check service-account.json and folder sharing.",
        );
    }
}

verify();
