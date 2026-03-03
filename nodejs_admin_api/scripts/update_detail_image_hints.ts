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

interface DetailImageHint {
    수목명: string;
    tree_id: number;
    잎_힌트?: string;
    수피_힌트?: string;
    꽃_힌트?: string;
    열매_힌트?: string;
    겨울눈_힌트?: string;
}

async function updateDetailImageHints() {
    console.log("🔄 Step 2: Updating detail image hints in database...\n");

    // Load hints data
    const dataPath = path.resolve(__dirname, "data/detail_image_hints.json");

    if (!fs.existsSync(dataPath)) {
        console.error(`❌ Data file not found: ${dataPath}`);
        console.error("Please run extract_detail_hints.ts first (Step 1)");
        process.exit(1);
    }

    const rawData = fs.readFileSync(dataPath, "utf-8");
    const hintsData: DetailImageHint[] = JSON.parse(rawData);

    console.log(`📦 Loaded ${hintsData.length} trees with detail hints\n`);

    let updatedCount = 0;
    let createdCount = 0;
    let skippedCount = 0;
    let errorCount = 0;

    for (const hintData of hintsData) {
        try {
            const treeName = hintData.수목명;
            const treeId = hintData.tree_id;

            console.log(`\n🔍 Processing: ${treeName} (ID: ${treeId})`);

            // Helper function to update or create image hint
            const updateImageHint = async (
                imageType: "leaf" | "bark" | "flower" | "fruit" | "bud",
                hint: string | undefined,
            ) => {
                if (!hint) return;

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
                            `  ✅ Updated ${imageType}: "${hint.substring(0, 40)}..."`,
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
                            is_quiz_enabled: false,
                        });

                    if (insertError) {
                        console.error(
                            `  ❌ Error creating ${imageType}:`,
                            insertError.message,
                        );
                        errorCount++;
                    } else {
                        console.log(
                            `  ➕ Created ${imageType}: "${hint.substring(0, 40)}..."`,
                        );
                        createdCount++;
                    }
                }
            };

            // Update all image types
            await updateImageHint("leaf", hintData.잎_힌트);
            await updateImageHint("bark", hintData.수피_힌트);
            await updateImageHint("flower", hintData.꽃_힌트);
            await updateImageHint("fruit", hintData.열매_힌트);
            await updateImageHint("bud", hintData.겨울눈_힌트);

            console.log(`  ✅ ${treeName} completed!`);
        } catch (e) {
            console.error(`  ❌ Exception:`, e);
            errorCount++;
        }
    }

    console.log("\n" + "=".repeat(70));
    console.log("🎉 Step 2 Completed: Detail Image Hints Update");
    console.log("=".repeat(70));
    console.log(`📊 Total trees processed: ${hintsData.length}`);
    console.log(`✅ Hints updated: ${updatedCount}`);
    console.log(`➕ Hints created: ${createdCount}`);
    console.log(`⏭️  Hints skipped: ${skippedCount}`);
    console.log(`❌ Errors: ${errorCount}`);
    console.log("=".repeat(70));
}

updateDetailImageHints();
