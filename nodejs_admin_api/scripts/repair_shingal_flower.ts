import { GoogleDriveService } from "../src/modules/external/google_drive.service";
import { UploadService } from "../src/modules/uploads/uploads.service";
import { supabase } from "../src/config/supabaseClient";
import dotenv from "dotenv";
import path from "path";

// Load .env from parent directory if needed, or local
dotenv.config();

async function repair() {
    const driveService = new GoogleDriveService();
    const treeName = "신갈나무";
    const imageType = "flower";
    const imageRecordId = 1327;

    console.log(
        `🚀 Repairing ${treeName} ${imageType} (ID: ${imageRecordId})...`,
    );

    try {
        // 1. Search for image in Drive
        const url = await driveService.searchImage(treeName, imageType);
        if (!url) {
            console.error("❌ Image not found in Google Drive query.");
            return;
        }
        console.log(`✅ Found Drive URL: ${url}`);

        // 2. Download from Drive (Using fixed logic in downloadFileAsBuffer)
        const fileId = url.split("id=")[1];
        if (!fileId) {
            console.error("❌ Invalid File ID from Drive URL.");
            return;
        }

        const buffer = await driveService.downloadFileAsBuffer(fileId);
        if (!buffer || buffer.length < 50000) {
            // Small buffer might be HTML still
            console.error(
                `❌ Download failed or returned small buffer (${buffer?.length} bytes).`,
            );
            if (buffer) console.log(buffer.toString().substring(0, 100));
            return;
        }

        console.log(`✅ Downloaded ${buffer.length} bytes from Google Drive.`);

        // 3. Upload to Supabase Storage
        const timestamp = Date.now();
        const fileName = `trees/${timestamp}_repair_shingal_flower.jpg`;
        const uploadResult = await UploadService.uploadBuffer(
            buffer,
            fileName,
            "image/jpeg",
        );
        console.log(
            `✅ Uploaded to Supabase Storage: ${uploadResult.publicUrl}`,
        );

        // 4. Update DB
        const { error: dbError } = await supabase
            .from("tree_images")
            .update({
                image_url: uploadResult.publicUrl,
                // We should also update thumbnail if we want, but original is priority
            })
            .eq("id", imageRecordId);

        if (dbError) {
            console.error("❌ DB Update Error:", dbError);
        } else {
            console.log("🎉 Successfully updated database record!");

            // Optional: check the record
            const { data: updated } = await supabase
                .from("tree_images")
                .select("*")
                .eq("id", imageRecordId)
                .single();
            console.log("Updated record image_url:", updated?.image_url);
        }
    } catch (error) {
        console.error("❌ Repair failed:", error);
    }
}

repair();
