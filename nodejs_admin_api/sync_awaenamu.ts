import { createClient } from "@supabase/supabase-js";
import { google } from "googleapis";
import dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.join(__dirname, ".env") });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

const GOOGLE_DRIVE_FOLDER_ID = "1GK_EJ3ZaJ8nzdH1JW7wD_bXn6RH6BxkT";
const API_KEY = process.env.GOOGLE_DRIVE_API_KEY;

const drive = google.drive({
    version: "v3",
    auth: API_KEY,
});

const imageTypes = ["main", "leaf", "bark", "flower", "fruit"];
const typeMap: Record<string, string> = {
    main: "대표",
    leaf: "잎",
    bark: "수피",
    flower: "꽃",
    fruit: "열매",
};

async function syncAwaenamu() {
    const treeName = "아왜나무";
    console.log(`🚀 Starting sync for ${treeName}...`);

    // 1. Get Tree ID
    const { data: tree } = await supabase
        .from("trees")
        .select("id")
        .eq("name_kr", treeName)
        .maybeSingle();

    if (!tree) {
        console.error("❌ Tree not found in DB.");
        return;
    }
    console.log(`✅ Tree found. ID: ${tree.id}`);

    for (const type of imageTypes) {
        const koreanType = typeMap[type];
        const searchTerm = `${treeName}_${koreanType}`;
        const query = `'${GOOGLE_DRIVE_FOLDER_ID}' in parents and name contains '${searchTerm}' and mimeType contains 'image/' and trashed = false`;

        console.log(`🔍 Searching Drive for: ${searchTerm}...`);

        try {
            const response = await drive.files.list({
                q: query,
                fields: "files(id, name)",
            });

            const files = response.data.files;
            if (files && files.length > 0) {
                const file = files[0];
                const driveUrl = `https://drive.google.com/uc?export=view&id=${file.id}`;
                console.log(`   ✨ Found: ${file.name} -> ${driveUrl}`);

                // Update Supabase
                const { error } = await supabase
                    .from("tree_images")
                    .update({ image_url: driveUrl })
                    .eq("tree_id", tree.id)
                    .eq("image_type", type);

                if (error) {
                    console.error(
                        `   ❌ Failed to update ${type} in DB:`,
                        error.message,
                    );
                } else {
                    console.log(`   ✅ Updated ${type} in DB.`);
                }
            } else {
                console.log(`   ⚠️ No file found for ${searchTerm}`);
            }
        } catch (e: any) {
            console.error(
                `   ❌ Error searching Drive for ${searchTerm}:`,
                e.message,
            );
        }
    }
    console.log("🏁 Sync completed.");
}

syncAwaenamu();
