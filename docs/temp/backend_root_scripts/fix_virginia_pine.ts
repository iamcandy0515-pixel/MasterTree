import * as dotenv from "dotenv";
import path from "path";
dotenv.config();

import { GoogleDriveService } from "./src/modules/external/google_drive.service";
import { supabase } from "./src/config/supabaseClient";

async function fix() {
    console.log("🚀 Starting Virginia Pine Recovery script...");
    console.log("- Initializing GoogleDriveService...");
    const gd = new GoogleDriveService();
    const files = [
        {
            id: "1ovTIv1hrIVr9T3SF5EH0LFIb5-8L7DAF",
            name: "버지니아소나무_꽃_thumb.webp",
            type: "flower",
        },
        {
            id: "1XPrMhAFJFRIyD5K17FHtbNMW3o8WWvwc",
            name: "버지니아소나무_열매_thumb.webp",
            type: "fruit",
        },
        {
            id: "10mr0MYYHEGhLY8RmM99wDQUsGYtsbAz2",
            name: "버지니아소나무_잎_thumb.webp",
            type: "leaf",
        },
        {
            id: "1QhB6iL3Oib6e-tjZMygLpQml73KodZ4C",
            name: "버지니아소나무_수피_thumb.webp",
            type: "bark",
        },
        {
            id: "1RU5soO2uS-FUCLDU9BJbED_o8pnq9FAg",
            name: "버지니아소나무_대표_thumb.webp",
            type: "main",
        },
    ];

    console.log("🚀 Starting Virginia Pine Recovery (Script File Path)...");

    for (const f of files) {
        try {
            console.log(`- Renaming [${f.id}] to [${f.name}]`);
            await gd.drive.files.update({
                fileId: f.id,
                requestBody: { name: f.name },
                supportsAllDrives: true,
            });

            const url = "https://drive.google.com/uc?export=view&id=" + f.id;
            console.log(`- Updating DB for ID 24, type: ${f.type}`);
            const { error } = await supabase
                .from("tree_images")
                .update({ thumbnail_url: url })
                .eq("tree_id", 24)
                .eq("image_type", f.type);

            if (error) throw error;
        } catch (err: any) {
            console.error(`❌ Error processing ${f.name}:`, err.message);
        }
    }

    console.log("✅ Virginia Pine Recovery Completed!");
    process.exit(0);
}

fix().catch((err) => {
    console.error("❌ Fatal Error:", err);
    process.exit(1);
});
