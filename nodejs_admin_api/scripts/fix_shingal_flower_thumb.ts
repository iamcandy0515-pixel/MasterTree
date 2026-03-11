import * as dotenv from "dotenv";
import path from "path";
dotenv.config({ path: path.resolve(__dirname, "../.env") });

import { createClient } from "@supabase/supabase-js";
import { GoogleDriveService } from "../src/modules/external/google_drive.service";
import { settingsService } from "../src/modules/settings/settings.service";

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);
const driveService = new GoogleDriveService();

async function run() {
    console.log("🌸 [Job] Generating '신갈나무_꽃' Thumbnail...");

    // 1. Get Shingal Flower Image Data from DB
    const { data: tree } = await supabase
        .from("trees")
        .select("id, name_kr")
        .eq("name_kr", "신갈나무")
        .single();
    if (!tree) throw new Error("신갈나무를 찾을 수 없습니다.");

    const { data: imageRecord } = await supabase
        .from("tree_images")
        .select("*")
        .eq("tree_id", tree.id)
        .eq("image_type", "flower")
        .single();

    if (!imageRecord || !imageRecord.image_url) {
        throw new Error(
            "신갈나무 꽃 원본 이미지가 DB에 등록되어 있지 않습니다.",
        );
    }

    console.log(`🔗 Original URL: ${imageRecord.image_url}`);

    // 2. Use our brand new Service Method to generate thumbnail
    try {
        const thumbUrl = await driveService.generateThumbnailFromUrl(
            imageRecord.image_url,
            tree.id,
            tree.name_kr,
            "flower",
        );

        console.log(`✅ Thumbnail Created & Uploaded: ${thumbUrl}`);

        // 3. Update DB
        const { error: updateError } = await supabase
            .from("tree_images")
            .update({ thumbnail_url: thumbUrl })
            .eq("id", imageRecord.id);

        if (updateError) {
            throw new Error(`DB 업데이트 실패: ${updateError.message}`);
        }

        console.log(
            "🎉 Successfully updated DB with '신갈나무_꽃' thumbnail URL.",
        );
    } catch (error: any) {
        console.error("❌ Thumbnail generation failed:", error.message);
    }
}

run();
