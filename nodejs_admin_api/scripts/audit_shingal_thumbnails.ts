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

const FALLBACK_THUMB_FOLDER_ID = "1DleUW8e0NVE07aYAEQLo7oraDSYtBOZa";

async function audit() {
    console.log(
        "🧐 [Audit] Checking Consistency for '신갈나무' Thumbnails...\n",
    );

    // 1. Get Tree & DB Image Data
    const { data: tree } = await supabase
        .from("trees")
        .select("id")
        .eq("name_kr", "신갈나무")
        .single();
    if (!tree) return console.error("Tree not found");

    const { data: dbImages } = await supabase
        .from("tree_images")
        .select("image_type, thumbnail_url")
        .eq("tree_id", tree.id);
    const dbMap = new Map();
    dbImages?.forEach((img) => {
        if (img.thumbnail_url) dbMap.set(img.image_type, img.thumbnail_url);
    });

    // 2. Get Drive Folder ID
    const thumbUrlFull = await settingsService
        .getTreeThumbnailDriveUrl()
        .catch(() => "");

    let folderId = "";
    if (thumbUrlFull) {
        if (thumbUrlFull.includes("folders/")) {
            folderId = thumbUrlFull.split("folders/")[1]?.split("?")[0];
        } else if (thumbUrlFull.includes("id=")) {
            folderId = thumbUrlFull.split("id=")[1]?.split("&")[0];
        } else {
            folderId = thumbUrlFull.split("/").pop() || "";
        }
    }

    if (!folderId || folderId.length < 10) {
        console.warn(
            `⚠️ Settings에 'tree_thumbnail_drive_url'이 없거나 잘못되었습니다. Fallback ID 사용: ${FALLBACK_THUMB_FOLDER_ID}`,
        );
        folderId = FALLBACK_THUMB_FOLDER_ID;
    }

    console.log(`📂 Target Folder: ${folderId}`);
    console.log("--------------------------------------------------");

    // 3. Search Drive files
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
        const kor = typeMapKM[type];
        const dbUrl = dbMap.get(type);

        // Extract DB File ID
        const dbIdMatch = dbUrl?.match(/id=([a-zA-Z0-9-_]+)/);
        const dbId = dbIdMatch ? dbIdMatch[1] : null;

        // Search Drive
        const q = `'${folderId}' in parents and name contains '신갈나무_${kor}' and trashed = false`;
        const resp = await driveService.drive.files.list({
            q,
            fields: "files(id, name)",
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
        });
        const driveFiles = resp.data.files || [];

        // Find best match (prefer files with 'thumb' in name if multiple)
        let driveFile =
            driveFiles.find((f) => f.name?.toLowerCase().includes("thumb")) ||
            driveFiles[0];

        console.log(`[${kor}]`);
        if (dbUrl) {
            console.log(`   - DB  URLID: ${dbId}`);
        } else {
            console.log(`   - DB  URLID: (EMPTY)`);
        }

        if (driveFile) {
            console.log(`   - DRV URLID: ${driveFile.id} (${driveFile.name})`);

            if (dbId === driveFile.id) {
                console.log("   ✅ MATCH: DB and Drive are in sync.");
            } else if (!dbUrl) {
                console.log(
                    "   ⚠️ MISSING: DB entry is empty, but file exists in Drive.",
                );
            } else {
                console.log(
                    "   ❌ MISMATCH: DB has a different file ID than Drive.",
                );
            }
        } else {
            console.log(
                "   ❌ NOT FOUND: No matching file in the specified Drive folder.",
            );
        }
        console.log("");
    }
}

audit().catch((err) => {
    console.error("❌ Audit Process Failed:", err.message);
    process.exit(1);
});
