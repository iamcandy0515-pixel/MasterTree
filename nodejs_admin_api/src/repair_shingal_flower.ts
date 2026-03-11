import "dotenv/config";
import { GoogleDriveService } from "./modules/external/google_drive.service";
import { UploadService } from "./modules/uploads/uploads.service";
import { supabase } from "./config/supabaseClient";

console.log("SUPABASE_URL:", process.env.SUPABASE_URL ? "Present" : "MISSING");
console.log(
    "SUPABASE_SERVICE_KEY:",
    process.env.SUPABASE_SERVICE_KEY ? "Present" : "MISSING",
);

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
        const url = await driveService.searchImage(treeName, imageType, "");
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
            console.error(
                `❌ Download failed or returned small buffer (${buffer?.length} bytes).`,
            );
            return;
        }

        console.log(`✅ Downloaded ${buffer.length} bytes from Google Drive.`);

        // 3. Upload to Supabase Storage
        const timestamp = Date.now();
        const fileName = `trees/${timestamp}_repair_shingal_flower.jpg`;
        const uploadResult = await UploadService.uploadToStorage({
            buffer,
            originalname: "repair_shingal_flower.jpg",
            mimetype: "image/jpeg",
            size: buffer.length
        } as any);
        console.log(
            `✅ Uploaded to Supabase Storage: ${uploadResult.publicUrl}`,
        );

        // 4. Update DB
        const { error: dbError } = await supabase
            .from("tree_images")
            .update({
                image_url: uploadResult.publicUrl,
            })
            .eq("id", imageRecordId);

        if (dbError) {
            console.error("❌ DB Update Error:", dbError);
        } else {
            console.log("🎉 Successfully updated database record!");
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
