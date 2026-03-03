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

interface MainImageHint {
    수목명: string;
    대표이미지_힌트: string;
}

async function updateMainImageHints() {
    console.log("🔄 Step 2: Updating main image hints in database...\n");

    // Load hints data
    const dataPath = path.resolve(__dirname, "data/main_image_hints.json");

    if (!fs.existsSync(dataPath)) {
        console.error(`❌ Data file not found: ${dataPath}`);
        console.error("Please ensure main_image_hints.json exists");
        process.exit(1);
    }

    const rawData = fs.readFileSync(dataPath, "utf-8");
    const hintsData: MainImageHint[] = JSON.parse(rawData);

    console.log(`📦 Loaded ${hintsData.length} main image hints\n`);

    let updatedCount = 0;
    let notFoundCount = 0;
    let errorCount = 0;

    for (const hintData of hintsData) {
        try {
            const treeName = hintData.수목명;
            const hint = hintData.대표이미지_힌트;

            console.log(`\n🔍 Processing: ${treeName}`);

            // Get tree ID
            const { data: tree, error: treeError } = await supabase
                .from("trees")
                .select("id")
                .eq("name_kr", treeName)
                .maybeSingle();

            if (treeError || !tree) {
                console.log(`  ⚠️  Tree not found in DB: ${treeName}`);
                notFoundCount++;
                continue;
            }

            // Find main image
            const { data: mainImage, error: findError } = await supabase
                .from("tree_images")
                .select("id, hint")
                .eq("tree_id", tree.id)
                .eq("image_type", "main")
                .maybeSingle();

            if (findError) {
                console.error(
                    `  ❌ Error finding main image:`,
                    findError.message,
                );
                errorCount++;
                continue;
            }

            if (!mainImage) {
                console.log(`  ⚠️  No main image found - skipping`);
                notFoundCount++;
                continue;
            }

            // Update hint
            const { error: updateError } = await supabase
                .from("tree_images")
                .update({ hint: hint })
                .eq("id", mainImage.id);

            if (updateError) {
                console.error(`  ❌ Error updating hint:`, updateError.message);
                errorCount++;
            } else {
                console.log(`  ✅ Updated: "${hint.substring(0, 50)}..."`);
                updatedCount++;
            }
        } catch (e) {
            console.error(`  ❌ Exception:`, e);
            errorCount++;
        }
    }

    console.log("\n" + "=".repeat(70));
    console.log("🎉 Step 2 Completed: Main Image Hints Update");
    console.log("=".repeat(70));
    console.log(`📊 Total hints processed: ${hintsData.length}`);
    console.log(`✅ Hints updated: ${updatedCount}`);
    console.log(`⚠️  Trees not found: ${notFoundCount}`);
    console.log(`❌ Errors: ${errorCount}`);
    console.log("=".repeat(70));
}

updateMainImageHints();
