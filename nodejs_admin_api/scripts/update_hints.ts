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

interface HintComparison {
    수목명: string;
    tree_id: number;
    changes: {
        image_type: string;
        current_hint: string | null;
        new_hint: string;
        status: "UPDATE" | "NO_CHANGE" | "NEW";
    }[];
}

async function updateHintsFromReport() {
    console.log("🔄 Step 2: Updating hints in database...\n");

    // Load comparison report
    const reportPath = path.resolve(
        __dirname,
        "data/hint_comparison_report.json",
    );

    if (!fs.existsSync(reportPath)) {
        console.error(`❌ Comparison report not found: ${reportPath}`);
        console.error("Please run compare_hints.ts first (Step 1)");
        process.exit(1);
    }

    const rawData = fs.readFileSync(reportPath, "utf-8");
    const comparisons: HintComparison[] = JSON.parse(rawData);

    console.log(`📦 Loaded ${comparisons.length} trees with hint changes\n`);

    let updatedCount = 0;
    let errorCount = 0;
    let totalChanges = 0;

    for (const comp of comparisons) {
        try {
            console.log(
                `\n🔍 Processing: ${comp.수목명} (ID: ${comp.tree_id})`,
            );

            for (const change of comp.changes) {
                totalChanges++;

                // Find the image record
                const { data: image, error: findError } = await supabase
                    .from("tree_images")
                    .select("id")
                    .eq("tree_id", comp.tree_id)
                    .eq("image_type", change.image_type)
                    .maybeSingle();

                if (findError) {
                    console.error(
                        `  ❌ Error finding ${change.image_type} image:`,
                        findError.message,
                    );
                    errorCount++;
                    continue;
                }

                if (!image) {
                    console.log(
                        `  ⚠️  No ${change.image_type} image found - skipping`,
                    );
                    continue;
                }

                // Update the hint
                const { error: updateError } = await supabase
                    .from("tree_images")
                    .update({ hint: change.new_hint || null })
                    .eq("id", image.id);

                if (updateError) {
                    console.error(
                        `  ❌ Error updating ${change.image_type} hint:`,
                        updateError.message,
                    );
                    errorCount++;
                } else {
                    console.log(
                        `  ✅ Updated ${change.image_type}: "${change.new_hint}"`,
                    );
                    updatedCount++;
                }
            }

            console.log(`  ✅ ${comp.수목명} completed!`);
        } catch (e) {
            console.error(`  ❌ Exception processing ${comp.수목명}:`, e);
            errorCount++;
        }
    }

    console.log("\n" + "=".repeat(70));
    console.log("🎉 Step 2 Completed: Database Update");
    console.log("=".repeat(70));
    console.log(`📊 Trees processed: ${comparisons.length}`);
    console.log(`✅ Hints updated: ${updatedCount}`);
    console.log(`❌ Errors: ${errorCount}`);
    console.log(`📝 Total changes attempted: ${totalChanges}`);
    console.log("=".repeat(70));
}

updateHintsFromReport();
