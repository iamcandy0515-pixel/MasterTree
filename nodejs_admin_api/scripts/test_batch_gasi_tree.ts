import * as dotenv from "dotenv";
import * as path from "path";
dotenv.config({ path: path.resolve(__dirname, "../.env") });

import { supabase } from "../src/config/supabaseClient";
import { settingsService } from "../src/modules/settings/settings.service";
import { GoogleDriveService } from "../src/modules/external/google_drive.service";
import { extractDriveFolderId } from "../src/utils/drive-helper";

async function runTest() {
    try {
        console.log("🚀 Starting batch update test for '가시나무'...");

        // 1. Get Google Drive Folder ID
        const folderUrl = await settingsService.getGoogleDriveFolderUrl();
        const folderId = extractDriveFolderId(folderUrl);
        if (!folderId) {
            console.error("❌ Google Drive folder URL is not configured or invalid.");
            return;
        }
        console.log(`✅ Extracted Folder ID: ${folderId}`);

        // 2. Fetch '가시나무' from Supabase
        const { data: trees, error: treeError } = await supabase
            .from("trees")
            .select("id, name_kr")
            .eq("name_kr", "가시나무");

        if (treeError || !trees || trees.length === 0) {
            console.error("❌ Failed to fetch '가시나무' from DB:", treeError);
            return;
        }

        const treeId = trees[0].id;
        console.log(`✅ Found '가시나무' in DB. Tree ID: ${treeId}`);

        const { data: treeImages, error: imgError } = await supabase
            .from("tree_images")
            .select("*")
            .eq("tree_id", treeId);

        if (imgError) {
             console.error("❌ Failed to fetch tree_images from DB:", imgError);
             return;
        }

        // 3. Search Google Drive
        const googleDriveService = new GoogleDriveService();
        const driveLinks = await googleDriveService.searchAllLinks("가시나무", folderId);
        console.log("🔍 Google Drive Links Found:", driveLinks);

        // 4. Validate & Update
        let matchCount = 0;
        let updateCount = 0;
        let errorCount = 0;

        for (const [type, driveUrl] of Object.entries(driveLinks)) {
            // Validation
            if (driveUrl.endsWith(".jpg") || driveUrl.endsWith(".png")) {
                 console.log(`⚠️ Format Error: The URL for ${type} ends with an extension (${driveUrl})`);
                 errorCount++;
                 continue;
            }
            if (!driveUrl.includes("https://drive.google.com/uc?export=view&id=")) {
                 console.log(`⚠️ Format Error: The URL for ${type} is not a valid view link (${driveUrl})`);
                 errorCount++;
                 continue;
            }

            const existingImage = treeImages?.find(img => img.image_type === type);

            if (!existingImage) {
                 console.log(`💡 No existing record for '${type}'. Performing INSERT.`);
                 const { error: insertError } = await supabase.from("tree_images").insert({
                     tree_id: treeId,
                     image_type: type,
                     image_url: driveUrl
                 });
                 if (insertError) {
                     console.error(`❌ Insert failed for ${type}:`, insertError);
                 } else {
                     console.log(`✅ Successfully inserted ${type}`);
                     updateCount++;
                 }
            } else if (existingImage.image_url !== driveUrl) {
                 console.log(`⚠️ URL mismatch for '${type}'. Updating...`);
                 console.log(`   - DB:    ${existingImage.image_url}`);
                 console.log(`   - Drive: ${driveUrl}`);
                 
                 const { error: updateError } = await supabase
                     .from("tree_images")
                     .update({ image_url: driveUrl })
                     .eq("id", existingImage.id);

                 if (updateError) {
                     console.error(`❌ Update failed for ${type}:`, updateError);
                 } else {
                     console.log(`✅ Successfully updated ${type}`);
                     updateCount++;
                 }
            } else {
                 console.log(`✅ '${type}' URL matches perfectly in DB. No update needed.`);
                 matchCount++;
            }
        }

        console.log("-----------------------------------------");
        console.log(`📊 Test Results: Matches: ${matchCount}, Updates/Inserts: ${updateCount}, Errors: ${errorCount}`);
        console.log("🎉 Test completed for '가시나무'.");

    } catch (e) {
        console.error("❌ Exception occurred:", e);
    }
}

runTest();
