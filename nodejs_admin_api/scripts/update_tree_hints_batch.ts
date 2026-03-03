import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";
import fs from "fs";

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, "../.env") });

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

interface TreeHintUpdate {
    수목명: string;
    tree_id: number;
    대표_힌트?: string;
    잎_힌트?: string;
    수피_힌트?: string;
    겨울눈_힌트?: string;
}

async function updateTreeHintsBatch() {
    console.log("🔄 Batch Update: Tree Hints from Batch Template...\n");

    // Load batch template data
    const dataPath = path.resolve(
        __dirname,
        "data/tree_hints_batch_template.json",
    );

    if (!fs.existsSync(dataPath)) {
        console.error(`❌ Batch template file not found: ${dataPath}`);
        console.error("Please create tree_hints_batch_template.json first");
        process.exit(1);
    }

    const rawData = fs.readFileSync(dataPath, "utf-8");
    const allData: TreeHintUpdate[] = JSON.parse(rawData);

    // Filter out empty entries
    const hintsData = allData.filter(
        (item) => item.tree_id > 0 && item.수목명 && item.수목명.trim() !== "",
    );

    console.log(`📦 Total entries in template: ${allData.length}`);
    console.log(`✅ Valid entries to process: ${hintsData.length}`);
    console.log(
        `⏭️  Skipped empty entries: ${allData.length - hintsData.length}\n`,
    );

    if (hintsData.length === 0) {
        console.error("❌ No valid entries found in template!");
        console.error("Please fill in at least one tree entry.");
        process.exit(1);
    }

    let updatedCount = 0;
    let createdCount = 0;
    let errorCount = 0;
    let skippedCount = 0;

    for (const hintData of hintsData) {
        try {
            const treeName = hintData.수목명;
            const treeId = hintData.tree_id;

            console.log(`\n🔍 Processing: ${treeName} (ID: ${treeId})`);

            // Verify tree exists
            const { data: tree, error: treeError } = await supabase
                .from("trees")
                .select("id, name_kr")
                .eq("id", treeId)
                .maybeSingle();

            if (treeError || !tree) {
                console.error(
                    `  ❌ Tree not found with ID ${treeId}. Skipping...`,
                );
                skippedCount++;
                continue;
            }

            if (tree.name_kr !== treeName) {
                console.warn(
                    `  ⚠️  Warning: Tree name mismatch! Expected "${treeName}", found "${tree.name_kr}"`,
                );
            }

            // Helper function to update or create image hint
            const updateImageHint = async (
                imageType: "main" | "leaf" | "bark" | "bud",
                hint: string | undefined,
            ) => {
                if (!hint || hint.trim() === "") return;

                // Find existing image
                const { data: existingImage, error: findError } = await supabase
                    .from("tree_images")
                    .select("id, hint, image_url")
                    .eq("tree_id", treeId)
                    .eq("image_type", imageType)
                    .maybeSingle();

                if (findError) {
                    console.error(
                        `  ❌ Error finding ${imageType}:`,
                        findError.message,
                    );
                    errorCount++;
                    return;
                }

                if (existingImage) {
                    // Update existing image hint
                    const { error: updateError } = await supabase
                        .from("tree_images")
                        .update({ hint: hint })
                        .eq("id", existingImage.id);

                    if (updateError) {
                        console.error(
                            `  ❌ Error updating ${imageType}:`,
                            updateError.message,
                        );
                        errorCount++;
                    } else {
                        console.log(
                            `  ✅ Updated ${imageType}: "${hint.substring(0, 50)}..."`,
                        );
                        updatedCount++;
                    }
                } else {
                    // Create new image record with NULL image_url
                    const { error: insertError } = await supabase
                        .from("tree_images")
                        .insert({
                            tree_id: treeId,
                            image_type: imageType,
                            image_url: null,
                            hint: hint,
                            is_quiz_enabled:
                                imageType === "main" ? true : false,
                        });

                    if (insertError) {
                        console.error(
                            `  ❌ Error creating ${imageType}:`,
                            insertError.message,
                        );
                        errorCount++;
                    } else {
                        console.log(
                            `  ➕ Created ${imageType}: "${hint.substring(0, 50)}..."`,
                        );
                        createdCount++;
                    }
                }
            };

            // Update all hint types
            await updateImageHint("main", hintData.대표_힌트);
            await updateImageHint("leaf", hintData.잎_힌트);
            await updateImageHint("bark", hintData.수피_힌트);
            await updateImageHint("bud", hintData.겨울눈_힌트);

            console.log(`  ✅ ${treeName} completed!`);
        } catch (e) {
            console.error(`  ❌ Exception:`, e);
            errorCount++;
        }
    }

    console.log("\n" + "=".repeat(70));
    console.log("🎉 Batch Update Completed");
    console.log("=".repeat(70));
    console.log(`📊 Total trees processed: ${hintsData.length}`);
    console.log(`✅ Hints updated: ${updatedCount}`);
    console.log(`➕ Hints created: ${createdCount}`);
    console.log(`⏭️  Trees skipped: ${skippedCount}`);
    console.log(`❌ Errors: ${errorCount}`);
    console.log("=".repeat(70));

    if (errorCount > 0) {
        console.log("\n⚠️  Some errors occurred. Please review the log above.");
    } else {
        console.log("\n✅ All operations completed successfully!");
    }
}

updateTreeHintsBatch();
