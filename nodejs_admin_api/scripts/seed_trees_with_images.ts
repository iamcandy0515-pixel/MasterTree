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

// JSON structure from tree-catalog-flat.json
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

    상태?: string;
    조회수?: number;
    생성일?: string;
    수정일?: string;
}

// Database schema for trees table
interface TreeRecord {
    name_kr: string;
    scientific_name: string | null;
    description: string | null;
    difficulty: number;
    category: string | null;
}

// Database schema for tree_images table
interface TreeImageRecord {
    tree_id: number;
    image_type: "main" | "leaf" | "bark" | "flower" | "fruit" | "bud";
    image_url: string;
    hint: string | null;
    is_quiz_enabled: boolean;
}

// Schema mapping validation
function validateSchemaMapping() {
    console.log("🔍 Schema Mapping Validation\n");
    console.log("=".repeat(70));
    console.log("📋 JSON → Database Mapping");
    console.log("=".repeat(70));

    const mappings = [
        {
            section: "trees table",
            fields: [
                { json: "수목명", db: "name_kr", type: "string" },
                { json: "학명", db: "scientific_name", type: "string | null" },
                { json: "설명", db: "description", type: "string | null" },
                {
                    json: "설명 (auto-extract)",
                    db: "category",
                    type: "string | null",
                },
                {
                    json: "설명 (auto-calculate)",
                    db: "difficulty",
                    type: "number",
                },
            ],
        },
        {
            section: "tree_images table",
            fields: [
                {
                    json: "대표이미지",
                    db: "image_url (type: main)",
                    type: "string",
                },
                {
                    json: "잎_이미지",
                    db: "image_url (type: leaf)",
                    type: "string",
                },
                { json: "잎_힌트", db: "hint", type: "string | null" },
                { json: "잎_활성화", db: "is_quiz_enabled", type: "boolean" },
                {
                    json: "수피_이미지",
                    db: "image_url (type: bark)",
                    type: "string",
                },
                { json: "수피_힌트", db: "hint", type: "string | null" },
                { json: "수피_활성화", db: "is_quiz_enabled", type: "boolean" },
                {
                    json: "꽃_이미지",
                    db: "image_url (type: flower)",
                    type: "string",
                },
                { json: "꽃_힌트", db: "hint", type: "string | null" },
                { json: "꽃_활성화", db: "is_quiz_enabled", type: "boolean" },
                {
                    json: "열매_이미지",
                    db: "image_url (type: fruit)",
                    type: "string",
                },
                { json: "열매_힌트", db: "hint", type: "string | null" },
                { json: "열매_활성화", db: "is_quiz_enabled", type: "boolean" },
                {
                    json: "겨울눈_이미지",
                    db: "image_url (type: bud)",
                    type: "string",
                },
                { json: "겨울눈_힌트", db: "hint", type: "string | null" },
                {
                    json: "겨울눈_활성화",
                    db: "is_quiz_enabled",
                    type: "boolean",
                },
            ],
        },
    ];

    mappings.forEach((mapping) => {
        console.log(`\n📊 ${mapping.section}`);
        console.log("-".repeat(70));
        mapping.fields.forEach((field) => {
            console.log(
                `  ${field.json.padEnd(25)} → ${field.db.padEnd(30)} (${field.type})`,
            );
        });
    });

    console.log("\n" + "=".repeat(70));
    console.log("⚠️  Unmapped JSON fields (will be ignored):");
    console.log("  - 상태 (status)");
    console.log("  - 조회수 (view_count)");
    console.log("  - 생성일 (created_at - will use DB default)");
    console.log("  - 수정일 (updated_at - will use DB default)");
    console.log("=".repeat(70));
}

// Extract category from description
function extractCategory(description?: string): string | null {
    if (!description) return null;
    const match = description.match(/\[구분\]\s*(침엽수|활엽수)/);
    return match ? match[1] : null;
}

// Calculate difficulty based on description complexity
function calculateDifficulty(description?: string): number {
    if (!description) return 1;
    const length = description.length;
    if (length > 300) return 3;
    if (length > 200) return 2;
    return 1;
}

async function upsertTreesFromCatalog() {
    console.log("🌲 Starting Tree Catalog Upsert (Insert or Update)...\n");

    // Validate schema mapping first
    validateSchemaMapping();

    console.log(
        "\n\n📋 Do you want to proceed with the upsert? (This will be auto-confirmed in script)",
    );
    console.log(
        "Press Ctrl+C to cancel, or the script will continue in 3 seconds...\n",
    );

    // Load JSON data
    const dataPath = path.resolve(__dirname, "data/tree-catalog-flat.json");

    if (!fs.existsSync(dataPath)) {
        console.error(`❌ Data file not found: ${dataPath}`);
        process.exit(1);
    }

    const rawData = fs.readFileSync(dataPath, "utf-8");
    const catalogData: TreeCatalogData[] = JSON.parse(rawData);

    console.log(`📦 Loaded ${catalogData.length} trees from catalog\n`);

    let insertedCount = 0;
    let updatedCount = 0;
    let errorCount = 0;
    let imageInsertedCount = 0;
    let imageUpdatedCount = 0;

    for (const treeData of catalogData) {
        try {
            const treeName = treeData.수목명;
            console.log(`\n🔍 Processing: ${treeName}`);

            // Extract metadata
            const category = extractCategory(treeData.설명);
            const difficulty = calculateDifficulty(treeData.설명);

            // Check if tree exists
            const { data: existing, error: checkError } = await supabase
                .from("trees")
                .select("id")
                .eq("name_kr", treeName)
                .maybeSingle();

            if (checkError) {
                console.error(
                    `  ❌ Error checking ${treeName}:`,
                    checkError.message,
                );
                errorCount++;
                continue;
            }

            let treeId: number;

            if (existing) {
                // UPDATE existing tree
                console.log(`  🔄 Updating existing tree (ID: ${existing.id})`);

                const { error: updateError } = await supabase
                    .from("trees")
                    .update({
                        scientific_name: treeData.학명 || null,
                        description: treeData.설명 || null,
                        difficulty: difficulty,
                        category: category,
                    })
                    .eq("id", existing.id);

                if (updateError) {
                    console.error(
                        `  ❌ Error updating ${treeName}:`,
                        updateError.message,
                    );
                    errorCount++;
                    continue;
                }

                treeId = existing.id;
                updatedCount++;
                console.log(
                    `  ✅ Tree updated (Category: ${category || "N/A"}, Difficulty: ${difficulty})`,
                );
            } else {
                // INSERT new tree
                console.log(`  ➕ Inserting new tree`);

                const { data: newTree, error: insertError } = await supabase
                    .from("trees")
                    .insert({
                        name_kr: treeName,
                        scientific_name: treeData.학명 || null,
                        description: treeData.설명 || null,
                        difficulty: difficulty,
                        category: category,
                    })
                    .select("id")
                    .single();

                if (insertError || !newTree) {
                    console.error(
                        `  ❌ Error inserting ${treeName}:`,
                        insertError?.message,
                    );
                    errorCount++;
                    continue;
                }

                treeId = newTree.id;
                insertedCount++;
                console.log(
                    `  ✅ Tree inserted (ID: ${treeId}, Category: ${category || "N/A"}, Difficulty: ${difficulty})`,
                );
            }

            // Prepare image records
            const imageRecords: Omit<TreeImageRecord, "tree_id">[] = [];

            // Main image
            if (treeData.대표이미지 && treeData.대표이미지.trim() !== "") {
                imageRecords.push({
                    image_type: "main",
                    image_url: treeData.대표이미지,
                    hint: null,
                    is_quiz_enabled: true,
                });
            }

            // Leaf
            if (treeData.잎_이미지 && treeData.잎_이미지.trim() !== "") {
                imageRecords.push({
                    image_type: "leaf",
                    image_url: treeData.잎_이미지,
                    hint: treeData.잎_힌트 || null,
                    is_quiz_enabled: treeData.잎_활성화 ?? true,
                });
            }

            // Bark
            if (treeData.수피_이미지 && treeData.수피_이미지.trim() !== "") {
                imageRecords.push({
                    image_type: "bark",
                    image_url: treeData.수피_이미지,
                    hint: treeData.수피_힌트 || null,
                    is_quiz_enabled: treeData.수피_활성화 ?? true,
                });
            }

            // Flower
            if (treeData.꽃_이미지 && treeData.꽃_이미지.trim() !== "") {
                imageRecords.push({
                    image_type: "flower",
                    image_url: treeData.꽃_이미지,
                    hint: treeData.꽃_힌트 || null,
                    is_quiz_enabled: treeData.꽃_활성화 ?? true,
                });
            }

            // Fruit
            if (treeData.열매_이미지 && treeData.열매_이미지.trim() !== "") {
                imageRecords.push({
                    image_type: "fruit",
                    image_url: treeData.열매_이미지,
                    hint: treeData.열매_힌트 || null,
                    is_quiz_enabled: treeData.열매_활성화 ?? true,
                });
            }

            // Bud
            if (
                treeData.겨울눈_이미지 &&
                treeData.겨울눈_이미지.trim() !== ""
            ) {
                imageRecords.push({
                    image_type: "bud",
                    image_url: treeData.겨울눈_이미지,
                    hint: treeData.겨울눈_힌트 || null,
                    is_quiz_enabled: treeData.겨울눈_활성화 ?? true,
                });
            }

            // Delete existing images and insert new ones (simpler than upsert for images)
            if (imageRecords.length > 0) {
                // Delete old images
                const { error: deleteError } = await supabase
                    .from("tree_images")
                    .delete()
                    .eq("tree_id", treeId);

                if (deleteError) {
                    console.log(
                        `  ⚠️  Warning deleting old images:`,
                        deleteError.message,
                    );
                }

                // Insert new images
                const imageRecordsWithTreeId = imageRecords.map((img) => ({
                    tree_id: treeId,
                    ...img,
                }));

                const { error: imageError } = await supabase
                    .from("tree_images")
                    .insert(imageRecordsWithTreeId);

                if (imageError) {
                    console.error(
                        `  ⚠️  Error inserting images:`,
                        imageError.message,
                    );
                } else {
                    console.log(`  📸 Upserted ${imageRecords.length} images`);
                    if (existing) {
                        imageUpdatedCount += imageRecords.length;
                    } else {
                        imageInsertedCount += imageRecords.length;
                    }
                }
            } else {
                console.log(`  ℹ️  No images to upsert`);
            }

            console.log(`  ✅ ${treeName} completed!`);
        } catch (e) {
            console.error(`  ❌ Exception processing tree:`, e);
            errorCount++;
        }
    }

    console.log("\n" + "=".repeat(70));
    console.log("🎉 Upsert Completed!");
    console.log("=".repeat(70));
    console.log(`📊 Total Trees Processed: ${catalogData.length}`);
    console.log(`➕ Trees Inserted: ${insertedCount}`);
    console.log(`🔄 Trees Updated: ${updatedCount}`);
    console.log(`❌ Errors: ${errorCount}`);
    console.log(`📸 Images Inserted: ${imageInsertedCount}`);
    console.log(`📸 Images Updated: ${imageUpdatedCount}`);
    console.log("=".repeat(70));
}

upsertTreesFromCatalog();
