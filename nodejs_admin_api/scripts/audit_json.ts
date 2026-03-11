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

async function run() {
    const { data: tree } = await supabase
        .from("trees")
        .select("id")
        .eq("name_kr", "신갈나무")
        .single();
    const { data: dbImages } = await supabase
        .from("tree_images")
        .select("image_type, thumbnail_url")
        .eq("tree_id", tree.id);

    let thumbUrlFull = await settingsService
        .getTreeThumbnailDriveUrl()
        .catch(() => "");
    let folderId = thumbUrlFull.includes("folders/")
        ? thumbUrlFull.split("folders/")[1]?.split("?")[0]
        : FALLBACK_THUMB_FOLDER_ID;

    const categories = ["main", "bark", "leaf", "flower", "fruit"];
    const typeMapKM: Record<string, string> = {
        main: "대표",
        bark: "수피",
        leaf: "잎",
        flower: "꽃",
        fruit: "열매",
    };
    const results = [];

    for (const type of categories) {
        const kor = typeMapKM[type];
        const dbUrl = dbImages?.find(
            (i) => i.image_type === type,
        )?.thumbnail_url;
        const dbId = dbUrl?.match(/id=([a-zA-Z0-9-_]+)/)?.[1];

        const q = `'${folderId}' in parents and name contains '신갈나무_${kor}' and trashed = false`;
        const resp = await driveService.drive.files.list({
            q,
            fields: "files(id, name)",
        });
        const driveFile = resp.data.files?.[0];

        results.push({
            category: kor,
            dbId: dbId || null,
            driveId: driveFile?.id || null,
            driveFileName: driveFile?.name || null,
            status:
                dbId && driveFile && dbId === driveFile.id
                    ? "MATCH"
                    : dbId
                      ? "MISMATCH"
                      : "MISSING_IN_DB",
        });
    }
    console.log(JSON.stringify(results, null, 2));
}
run();
