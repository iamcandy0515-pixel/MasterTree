import * as dotenv from "dotenv";
import * as path from "path";
dotenv.config({ path: path.resolve(__dirname, "../.env") });

import { supabase } from "../src/config/supabaseClient";
import { settingsService } from "../src/modules/settings/settings.service";
import { GoogleDriveService } from "../src/modules/external/google_drive.service";
import { extractDriveFolderId } from "../src/utils/drive-helper";

async function runFullBatch() {
    try {
        console.log("🚀 Starting SUPER BATCH update for ALL Trees...");

        // 1. Get Folder ID
        const folderUrl = await settingsService.getGoogleDriveFolderUrl();
        const folderId = extractDriveFolderId(folderUrl);
        if (!folderId) {
            console.error("❌ Google Drive folder URL is not configured or invalid.");
            return;
        }
        console.log(`✅ Extracted Google Drive Folder ID: ${folderId}`);

        // 2. Fetch all trees
        const { data: trees, error: treeError } = await supabase
            .from("trees")
            .select("id, name_kr");

        if (treeError || !trees || trees.length === 0) {
            console.error("❌ Failed to fetch trees from DB:", treeError);
            return;
        }

        console.log(`✅ Fetched ${trees.length} trees from DB.`);

        // Gather all existing tree images for faster local matching
        const { data: allImages, error: imgError } = await supabase
            .from("tree_images")
            .select("*");

        if (imgError) {
             console.error("❌ Failed to fetch tree_images from DB:", imgError);
             return;
        }

        const googleDriveService = new GoogleDriveService();

        let totalMatches = 0;
        let totalUpdates = 0;
        let totalErrors = 0;

        for (const tree of trees) {
            console.log(`\n🌲 Processing: ${tree.name_kr} (ID: ${tree.id})`);

            // 3. Search Google Drive for this tree
            const driveLinks = await googleDriveService.searchAllLinks(tree.name_kr, folderId);
            
            if (Object.keys(driveLinks).length === 0) {
                console.log(`   🔸 No images found in Drive for ${tree.name_kr}`);
                continue;
            }

            const treeImages = allImages?.filter(img => img.tree_id === tree.id) || [];

            // 4. Validate & Update
            for (const [type, driveUrl] of Object.entries(driveLinks)) {
                // Validation
                if (driveUrl.endsWith(".jpg") || driveUrl.endsWith(".png")) {
                     console.log(`   ⚠️ Format Error (${type}): Ends with extension => ${driveUrl}`);
                     totalErrors++;
                     continue;
                }
                if (!driveUrl.includes("https://drive.google.com/uc?export=view&id=")) {
                     console.log(`   ⚠️ Format Error (${type}): Invalid URL format => ${driveUrl}`);
                     totalErrors++;
                     continue;
                }

                const existingImage = treeImages.find(img => img.image_type === type);

                if (!existingImage) {
                     console.log(`   💡 Performing INSERT for new '${type}' image.`);
                     const { error: insertError } = await supabase.from("tree_images").insert({
                         tree_id: tree.id,
                         image_type: type,
                         image_url: driveUrl
                     });
                     if (insertError) {
                         console.error(`   ❌ Insert failed:`, insertError);
                         totalErrors++;
                     } else {
                         console.log(`   ✅ Inserted ${type}`);
                         totalUpdates++;
                     }
                } else if (existingImage.image_url !== driveUrl) {
                     console.log(`   ⚠️ URL mismatch for '${type}'. Updating DB...`);
                     const { error: updateError } = await supabase
                         .from("tree_images")
                         .update({ image_url: driveUrl })
                         .eq("id", existingImage.id);

                     if (updateError) {
                         console.error(`   ❌ Update failed:`, updateError);
                         totalErrors++;
                     } else {
                         console.log(`   ✅ Updated ${type}`);
                         totalUpdates++;
                     }
                } else {
                     console.log(`   ✅ '${type}' URL matches perfectly. No update needed.`);
                     totalMatches++;
                }
            }
        }

        console.log("\n=========================================================");
        console.log(`🎉 SUPER BATCH COMPLETE!`);
        console.log(`📊 Final Results:`);
        console.log(`   - Perfect Matches (Skipped): ${totalMatches}`);
        console.log(`   - Updates & Inserts applied:  ${totalUpdates}`);
        console.log(`   - Format Errors / Failures:   ${totalErrors}`);
        console.log("=========================================================");

    } catch (e) {
        console.error("❌ Exception during Full Batch Execution:", e);
    }
}

runFullBatch();
