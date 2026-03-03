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

interface TreeCatalogData {
    수목명: string;
    학명?: string;
    설명?: string;
    대표이미지?: string;

    잎_힌트?: string;
    잎_이미지?: string;
    잎_활성화?: boolean;

    수피_힌트?: string;
    수피_이미지?: string;
    수피_활성화?: boolean;

    꽃_힌트?: string;
    꽃_이미지?: string;
    꽃_활성화?: boolean;

    열매_힌트?: string;
    열매_이미지?: string;
    열매_활성화?: boolean;

    겨울눈_힌트?: string;
    겨울눈_이미지?: string;
    겨울눈_활성화?: boolean;
}

async function createMissingImageRecords() {
    console.log("🔧 Migration: Creating missing image records with hints...\n");

    // Load JSON data
    const dataPath = path.resolve(__dirname, "data/tree-catalog-flat.json");

    if (!fs.existsSync(dataPath)) {
        console.error(`❌ Data file not found: ${dataPath}`);
        process.exit(1);
    }

    const rawData = fs.readFileSync(dataPath, "utf-8");
    const catalogData: TreeCatalogData[] = JSON.parse(rawData);

    console.log(`📦 Loaded ${catalogData.length} trees from catalog\n`);

    let createdCount = 0;
    let updatedCount = 0;
    let skippedCount = 0;
    let errorCount = 0;

    for (const treeData of catalogData) {
        try {
            const treeName = treeData.수목명;
            console.log(`\n🔍 Processing: ${treeName}`);

            // Get tree from database
            const { data: tree, error: treeError } = await supabase
                .from("trees")
                .select("id")
                .eq("name_kr", treeName)
                .maybeSingle();

            if (treeError || !tree) {
                console.log(`  ⚠️  Tree not found in DB: ${treeName}`);
                continue;
            }

            const treeId = tree.id;

            // Get existing images
            const { data: existingImages, error: imagesError } = await supabase
                .from("tree_images")
                .select("image_type, hint")
                .eq("tree_id", treeId);

            if (imagesError) {
                console.error(
                    `  ❌ Error fetching images:`,
                    imagesError.message,
                );
                errorCount++;
                continue;
            }

            // Helper function to process each image type
            const processImageType = async (
                imageType: "leaf" | "bark" | "flower" | "fruit" | "bud",
                imageUrl: string | undefined,
                hint: string | undefined,
                isEnabled: boolean | undefined,
            ) => {
                const existingImage = existingImages?.find(
                    (img) => img.image_type === imageType,
                );

                const normalizedHint = (hint || "").trim();

                // Skip if no hint and no image
                if (!normalizedHint && !imageUrl) {
                    return;
                }

                if (existingImage) {
                    // Update existing image if hint is different
                    const currentHint = (existingImage.hint || "").trim();
                    if (currentHint !== normalizedHint && normalizedHint) {
                        const { error: updateError } = await supabase
                            .from("tree_images")
                            .update({ hint: normalizedHint || null })
                            .eq("tree_id", treeId)
                            .eq("image_type", imageType);

                        if (updateError) {
                            console.error(
                                `  ❌ Error updating ${imageType}:`,
                                updateError.message,
                            );
                            errorCount++;
                        } else {
                            console.log(
                                `  🔄 Updated ${imageType} hint: "${normalizedHint}"`,
                            );
                            updatedCount++;
                        }
                    } else {
                        console.log(`  ⏭️  ${imageType} hint unchanged`);
                        skippedCount++;
                    }
                } else {
                    // Create new image record with placeholder URL if needed
                    const placeholderUrl =
                        imageUrl ||
                        `https://placehold.co/400x400/CCCCCC/666666?text=${encodeURIComponent(treeName)}+${imageType}`;

                    const { error: insertError } = await supabase
                        .from("tree_images")
                        .insert({
                            tree_id: treeId,
                            image_type: imageType,
                            image_url: placeholderUrl,
                            hint: normalizedHint || null,
                            is_quiz_enabled: isEnabled ?? false,
                        });

                    if (insertError) {
                        console.error(
                            `  ❌ Error creating ${imageType}:`,
                            insertError.message,
                        );
                        errorCount++;
                    } else {
                        console.log(
                            `  ➕ Created ${imageType} with hint: "${normalizedHint}"`,
                        );
                        createdCount++;
                    }
                }
            };

            // Process all image types
            await processImageType(
                "leaf",
                treeData.잎_이미지,
                treeData.잎_힌트,
                treeData.잎_활성화,
            );
            await processImageType(
                "bark",
                treeData.수피_이미지,
                treeData.수피_힌트,
                treeData.수피_활성화,
            );
            await processImageType(
                "flower",
                treeData.꽃_이미지,
                treeData.꽃_힌트,
                treeData.꽃_활성화,
            );
            await processImageType(
                "fruit",
                treeData.열매_이미지,
                treeData.열매_힌트,
                treeData.열매_활성화,
            );
            await processImageType(
                "bud",
                treeData.겨울눈_이미지,
                treeData.겨울눈_힌트,
                treeData.겨울눈_활성화,
            );

            console.log(`  ✅ ${treeName} completed!`);
        } catch (e) {
            console.error(`  ❌ Exception:`, e);
            errorCount++;
        }
    }

    console.log("\n" + "=".repeat(70));
    console.log("🎉 Migration Completed!");
    console.log("=".repeat(70));
    console.log(`📊 Total trees processed: ${catalogData.length}`);
    console.log(`➕ Image records created: ${createdCount}`);
    console.log(`🔄 Image records updated: ${updatedCount}`);
    console.log(`⏭️  Records skipped (no change): ${skippedCount}`);
    console.log(`❌ Errors: ${errorCount}`);
    console.log("=".repeat(70));
}

createMissingImageRecords();
