import * as dotenv from "dotenv";
import path from "path";
// Load environment variables IMMEDIATELY before other imports
dotenv.config({ path: path.resolve(__dirname, "../.env") });

import { createClient } from "@supabase/supabase-js";
import { GoogleDriveService } from "../src/modules/external/google_drive.service";
import { settingsService } from "../src/modules/settings/settings.service";

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);
const driveService = new GoogleDriveService();

// Default 썸네일 폴더 ID (batch_generate_thumbnails.ts 참조)
const FALLBACK_THUMB_FOLDER_ID = "1DleUW8e0NVE07aYAEQLo7oraDSYtBOZa";

async function run() {
    console.log("🚀 Starting Shingal Tree Thumbnail Sync (Batch Pattern)...");

    // 1. Get Shingal Tree (신갈나무) info
    const { data: tree, error: treeError } = await supabase
        .from("trees")
        .select("id, name_kr")
        .eq("name_kr", "신갈나무")
        .single();

    if (treeError || !tree) {
        console.error(
            "❌ Could not find Shingal tree in DB:",
            treeError?.message,
        );
        process.exit(1);
    }
    console.log(`🌳 Found Tree: ${tree.name_kr} (ID: ${tree.id})`);

    // 2. Get Thumbnail Folder from Settings
    let thumbFolderUrl = await settingsService
        .getTreeThumbnailDriveUrl()
        .catch(() => "");
    let thumbFolderId = "";

    if (thumbFolderUrl) {
        if (thumbFolderUrl.includes("folders/")) {
            thumbFolderId = thumbFolderUrl.split("folders/")[1]?.split("?")[0];
        } else {
            thumbFolderId = thumbFolderUrl.split("/").pop() || "";
        }
    }

    if (!thumbFolderId || thumbFolderId.length < 20) {
        console.warn(
            `⚠️ Settings에 썸네일 폴더가 없거나 잘못되었습니다. Fallback ID 사용: ${FALLBACK_THUMB_FOLDER_ID}`,
        );
        thumbFolderId = FALLBACK_THUMB_FOLDER_ID;
    } else {
        console.log(`📂 Thumbnail Folder ID from Settings: ${thumbFolderId}`);
    }

    // 3. Search images in that folder for Shingal
    // 신갈나무_대표, 신갈나무_수피, 신갈나무_잎, 신갈나무_꽃, 신갈나무_열매
    const categories: ("main" | "bark" | "leaf" | "flower" | "fruit")[] = [
        "main",
        "bark",
        "leaf",
        "flower",
        "fruit",
    ];
    const typeMapKM: Record<string, string> = {
        main: "대표",
        bark: "수피",
        leaf: "잎",
        flower: "꽃",
        fruit: "열매",
    };

    for (const type of categories) {
        const koreanType = typeMapKM[type];
        const searchTerm = `${tree.name_kr}_${koreanType}`;

        console.log(`🔍 Searching for: ${searchTerm}...`);

        // batch_generate_thumbnails.ts와 동일하게 thumb 키워드 포함 확인 로직 추가 가능하지만,
        // 여기서는 명시적으로 신갈나무_카테고리 매칭만 확인
        const q = `'${thumbFolderId}' in parents and name contains '${searchTerm}' and trashed = false`;
        const resp = await driveService.drive.files.list({
            q: q,
            fields: "files(id, name)",
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
            pageSize: 10,
        });

        const files = resp.data.files || [];
        if (files.length > 0) {
            // 가장 유사한 파일 선택 (보통 첫 번째)
            const file = files[0];
            const url = `https://drive.google.com/uc?export=view&id=${file.id}`;
            console.log(`   ✅ Found: ${file.name} -> ${url}`);

            // Update DB (image_type과 tree_id로 매칭)
            const { error: upError } = await supabase
                .from("tree_images")
                .update({ thumbnail_url: url })
                .eq("tree_id", tree.id)
                .eq("image_type", type);

            if (upError) {
                console.error(
                    `   ❌ Failed to update DB for ${type}:`,
                    upError.message,
                );
            } else {
                console.log(`   💾 DB Updated for ${type}.`);
            }
        } else {
            console.log(
                `   ❓ No matching file found for ${type} in the folder.`,
            );
        }
    }

    console.log("\n🏁 Finished Shingal Tree Thumbnail Sync.");
}

run().catch(console.error);
