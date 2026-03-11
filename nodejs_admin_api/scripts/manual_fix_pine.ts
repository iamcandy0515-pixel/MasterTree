import * as dotenv from "dotenv";
import path from "path";
dotenv.config();

import { GoogleDriveService } from "../src/modules/external/google_drive.service";
import { supabase } from "../src/config/supabaseClient";

const gd = new GoogleDriveService();

async function run() {
    console.log(
        "🏁 Starting Manual Fix for Pine (63) and Virginia Pine (24)...",
    );

    // 1. 버지니아소나무 (ID 24) 복구
    // 현재 이름이 '소나무_..._thumb.webp'로 되어 있는 파일들을 찾아 '버지니아소나무_..._thumb.webp'로 변경
    console.log("\n--- Part 1: Fix Virginia Pine (24) ---");
    const virginiaFiles = await gd.drive.files.list({
        q: "name contains '소나무' and name contains 'thumb' and trashed = false",
        fields: "files(id, name)",
    });

    for (const f of virginiaFiles.data.files || []) {
        if (f.name.startsWith("소나무_")) {
            const newName = f.name.replace("소나무_", "버지니아소나무_");
            console.log(
                `🔄 Renaming [${f.name}] to [${newName}] (ID: ${f.id})`,
            );
            await gd.drive.files.update({
                fileId: f.id,
                requestBody: { name: newName },
                supportsAllDrives: true,
            });

            // DB 업데이트
            const type = f.name.includes("대표")
                ? "main"
                : f.name.includes("잎")
                  ? "leaf"
                  : f.name.includes("수피")
                    ? "bark"
                    : f.name.includes("꽃")
                      ? "flower"
                      : f.name.includes("열매")
                        ? "fruit"
                        : null;

            if (type) {
                const url = `https://drive.google.com/uc?export=view&id=${f.id}`;
                await supabase
                    .from("tree_images")
                    .update({ thumbnail_url: url })
                    .eq("tree_id", 24)
                    .eq("image_type", type);
                console.log(
                    `✅ DB Updated for Virginia Pine (ID 24) [${type}]`,
                );
            }
        }
    }

    // 2. 소나무 (ID 63) 명명
    // 현재 이름이 '63_..._thumb...'로 되어 있는 파일들을 찾아 '소나무_..._thumb.webp'로 변경
    console.log("\n--- Part 2: Fix Pine (63) ---");
    const pineFiles = await gd.drive.files.list({
        q: "name contains '63_' and name contains 'thumb' and trashed = false",
        fields: "files(id, name)",
    });

    for (const f of pineFiles.data.files || []) {
        let type = f.name.includes("main")
            ? "대표"
            : f.name.includes("leaf")
              ? "잎"
              : f.name.includes("bark")
                ? "수피"
                : f.name.includes("flower")
                  ? "꽃"
                  : f.name.includes("fruit")
                    ? "열매"
                    : null;

        if (type) {
            const newName = `소나무_${type}_thumb.webp`;
            console.log(
                `🔄 Renaming [${f.name}] to [${newName}] (ID: ${f.id})`,
            );
            await gd.drive.files.update({
                fileId: f.id,
                requestBody: { name: newName },
                supportsAllDrives: true,
            });

            // DB 업데이트
            const typeEng =
                type === "대표"
                    ? "main"
                    : type === "잎"
                      ? "leaf"
                      : type === "수피"
                        ? "bark"
                        : type === "꽃"
                          ? "flower"
                          : "fruit";

            const url = `https://drive.google.com/uc?export=view&id=${f.id}`;
            await supabase
                .from("tree_images")
                .update({ thumbnail_url: url })
                .eq("tree_id", 63)
                .eq("image_type", typeEng);
            console.log(`✅ DB Updated for Pine (ID 63) [${typeEng}]`);
        }
    }

    console.log("\n✨ All fixes applied!");
    process.exit(0);
}

run().catch((err) => {
    console.error("❌ Fatal Error:", err);
    process.exit(1);
});
