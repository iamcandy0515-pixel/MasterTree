import * as dotenv from "dotenv";
import path from "path";
// Load environment variables IMMEDIATELY before other imports
dotenv.config({ path: path.resolve(__dirname, "../.env") });

import { createClient } from "@supabase/supabase-js";
import { GoogleDriveService } from "../src/modules/external/google_drive.service";

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});

const driveService = new GoogleDriveService();

/**
 * Find a folder by name
 */
async function findFolder(name: string) {
    console.log(`🔍 Searching folder: ${name}`);
    const resp = await driveService.drive.files.list({
        q: `name = '${name}' and mimeType = 'application/vnd.google-apps.folder' and trashed = false`,
        fields: "files(id, name)",
        supportsAllDrives: true,
        includeItemsFromAllDrives: true,
    });
    return resp.data.files?.[0];
}

/**
 * Find a file in a folder by multiple heuristic patterns
 */
async function findFileInFolder(
    folderId: string,
    treeId: number,
    treeName: string,
    koreanType: string,
    englishType: string,
    isThumb: boolean,
) {
    // 1. Pattern: [tree_name]_[korean_type] (e.g. 소나무_대표)
    // 2. Pattern: [tree_id]_[english_type] (e.g. 45_main)
    const patterns = isThumb
        ? [`${treeName}_${koreanType}`, `${treeId}_${englishType}`]
        : [`${treeName}_${koreanType}`];

    for (const keyword of patterns) {
        const resp = await driveService.drive.files.list({
            q: `'${folderId}' in parents and name contains '${keyword}' and trashed = false`,
            fields: "files(id, name)",
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
            pageSize: 20,
        });

        const files = resp.data.files || [];
        for (const file of files) {
            const fileName = file.name || "";
            const nameLower = fileName.toLowerCase();

            if (isThumb) {
                // Must have thumb signature
                if (nameLower.includes("thumb") || nameLower.includes("_t."))
                    return file;
            } else {
                // Must NOT have thumb signature
                if (!nameLower.includes("thumb") && !nameLower.includes("_t."))
                    return file;
            }
        }

        // Final fallback if no signature match but name is very similar
        if (files.length > 0) return files[0];
    }

    return null;
}

/**
 * Update Google Drive file name
 */
async function renameDriveFile(fileId: string, newName: string) {
    try {
        await driveService.drive.files.update({
            fileId: fileId,
            requestBody: { name: newName },
            supportsAllDrives: true,
        });
        return true;
    } catch (e: any) {
        console.error(`      ❌ Drive Rename Error (${fileId}): ${e.message}`);
        return false;
    }
}

async function run() {
    const args = process.argv.slice(2);
    const testIdx = args.indexOf("--test");
    const testMode = testIdx !== -1;
    const testTreeName = testMode ? args[testIdx + 1] : null;
    const allMode = args.includes("--all");

    if (!testMode && !allMode) {
        console.log(
            "Usage: npx ts-node scripts/sync_all_tree_images.ts [--test 'TreeName' | --all]",
        );
        process.exit(0);
    }

    // 1. Find the necessary Google Drive folders
    const treesQuizFolder = await findFolder("TreesQuiz");
    const thumbnailsFolder = await findFolder("TreesQuizThumbnail");

    if (!treesQuizFolder || !thumbnailsFolder) {
        console.error("❌ Critical Folders not found in Google Drive.");
        process.exit(1);
    }

    console.log(`✅ TreesQuiz Folder ID: ${treesQuizFolder.id}`);
    console.log(`✅ TreesQuizThumbnail Folder ID: ${thumbnailsFolder.id}`);

    // 2. Fetch trees from Supabase
    let query = supabase.from("trees").select(`
        id,
        name_kr,
        tree_images (
            id,
            image_type,
            image_url,
            thumbnail_url
        )
    `);

    if (testMode && testTreeName) {
        console.log(`🧪 Running TEST synchronization for: [${testTreeName}]`);
        query = query.eq("name_kr", testTreeName);
    } else {
        console.log("🚀 Running FULL synchronization for all trees...");
    }

    const { data: trees, error } = await query;
    if (error || !trees) {
        console.error("❌ Error fetching trees from DB:", error?.message);
        process.exit(1);
    }

    console.log(`📊 Loaded ${trees.length} trees. Starting sync...`);

    const categories: (
        | "main"
        | "leaf"
        | "bark"
        | "flower"
        | "fruit"
        | "bud"
    )[] = ["main", "leaf", "bark", "flower", "fruit", "bud"];

    const typeMap: Record<string, string> = {
        main: "대표",
        leaf: "잎",
        bark: "수피",
        flower: "꽃",
        fruit: "열매",
        bud: "겨울눈",
    };

    let processedCount = 0;
    let thumbRenamedCount = 0;
    let originalRecoveredCount = 0;

    for (const tree of trees) {
        console.log(`\n──────────────────────────────────────────────────`);
        console.log(`🌳 [${tree.name_kr}] (ID: ${tree.id})`);

        for (const type of categories) {
            const koreanType = typeMap[type];
            let existingImage = (tree.tree_images as any[]).find(
                (img) => img.image_type === type,
            );

            // A. Recover Original if missing from DB
            if (!existingImage || !existingImage.image_url) {
                console.log(
                    `   🔸 [${koreanType}] Original URL missing in DB. Searching TreesQuiz...`,
                );
                // Search in TreesQuiz
                const originalFile = await findFileInFolder(
                    treesQuizFolder.id,
                    tree.id,
                    tree.name_kr,
                    koreanType,
                    type,
                    false,
                );

                if (originalFile) {
                    const url = `https://drive.google.com/uc?export=view&id=${originalFile.id}`;
                    console.log(
                        `      ✅ Found: "${originalFile.name}" -> Recovering URL...`,
                    );

                    if (existingImage) {
                        const { error: upError } = await supabase
                            .from("tree_images")
                            .update({ image_url: url })
                            .eq("id", existingImage.id);
                        if (!upError) originalRecoveredCount++;
                    } else {
                        const { data: newImg, error: insError } = await supabase
                            .from("tree_images")
                            .insert({
                                tree_id: tree.id,
                                image_type: type,
                                image_url: url,
                                is_quiz_enabled: true,
                            })
                            .select()
                            .single();
                        if (!insError) {
                            existingImage = newImg;
                            originalRecoveredCount++;
                        }
                    }
                } else {
                    console.log(`      ❌ No original found in TreesQuiz.`);
                }
            }

            // B. Rename & Sync Thumbnail
            // We search for thumbnails regardless of whether the URL is present, to ensure the NAME is standard.
            console.log(
                `   🔹 [${koreanType}] Checking thumbnail in TreesQuizThumbnail...`,
            );
            const thumbFile = await findFileInFolder(
                thumbnailsFolder.id,
                tree.id,
                tree.name_kr,
                koreanType,
                type,
                true,
            );

            if (thumbFile) {
                const standardName = `${tree.name_kr}_${koreanType}_thumb.webp`;
                const newUrl = `https://drive.google.com/uc?export=view&id=${thumbFile.id}`;

                // Rename if needed
                if (thumbFile.name !== standardName) {
                    console.log(
                        `      🔄 Renaming Drive File: "${thumbFile.name}" -> "${standardName}"`,
                    );
                    const success = await renameDriveFile(
                        thumbFile.id,
                        standardName,
                    );
                    if (success) thumbRenamedCount++;
                } else {
                    console.log(`      ✅ Drive filename is already standard.`);
                }

                // Update DB URL if needed
                if (existingImage && existingImage.thumbnail_url !== newUrl) {
                    console.log(`      💾 Syncing DB thumbnail_url...`);
                    await supabase
                        .from("tree_images")
                        .update({ thumbnail_url: newUrl })
                        .eq("id", existingImage.id);
                }
            } else {
                console.log(`      ❓ No matching thumbnail found in Drive.`);
            }
        }
        processedCount++;
    }

    console.log(`\n${"=".repeat(50)}`);
    console.log(`✨ Sync Completed!`);
    console.log(`📊 Trees Processed: ${processedCount}`);
    console.log(`📸 Originals Recovered: ${originalRecoveredCount}`);
    console.log(`📁 Thumbnails Renamed: ${thumbRenamedCount}`);
    console.log(`${"=".repeat(50)}`);
}

run();
