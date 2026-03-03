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

async function compareHints() {
    console.log("🔍 Step 1: Comparing hints between JSON and Database...\n");

    // Load JSON data
    const dataPath = path.resolve(__dirname, "data/tree-catalog-flat.json");

    if (!fs.existsSync(dataPath)) {
        console.error(`❌ Data file not found: ${dataPath}`);
        process.exit(1);
    }

    const rawData = fs.readFileSync(dataPath, "utf-8");
    const catalogData: TreeCatalogData[] = JSON.parse(rawData);

    console.log(`📦 Loaded ${catalogData.length} trees from catalog\n`);

    const comparisons: HintComparison[] = [];
    let totalChanges = 0;
    let treesWithChanges = 0;

    for (const treeData of catalogData) {
        const treeName = treeData.수목명;

        // Get tree from database
        const { data: tree, error: treeError } = await supabase
            .from("trees")
            .select("id")
            .eq("name_kr", treeName)
            .maybeSingle();

        if (treeError || !tree) {
            console.log(`⚠️  Tree not found in DB: ${treeName}`);
            continue;
        }

        // Get current images with hints
        const { data: images, error: imagesError } = await supabase
            .from("tree_images")
            .select("image_type, hint")
            .eq("tree_id", tree.id);

        if (imagesError) {
            console.error(`❌ Error fetching images for ${treeName}`);
            continue;
        }

        const changes: HintComparison["changes"] = [];

        // Helper function to compare hints
        const compareHint = (
            imageType: string,
            jsonHint: string | undefined,
            currentImages: typeof images,
        ) => {
            const currentImage = currentImages?.find(
                (img) => img.image_type === imageType,
            );
            const currentHint = currentImage?.hint || "";
            const newHint = jsonHint || "";

            // Normalize for comparison (trim whitespace)
            const normalizedCurrent = currentHint.trim();
            const normalizedNew = newHint.trim();

            if (normalizedCurrent !== normalizedNew) {
                if (currentImage) {
                    changes.push({
                        image_type: imageType,
                        current_hint: currentHint,
                        new_hint: newHint,
                        status: "UPDATE",
                    });
                    totalChanges++;
                } else if (newHint) {
                    changes.push({
                        image_type: imageType,
                        current_hint: null,
                        new_hint: newHint,
                        status: "NEW",
                    });
                    totalChanges++;
                }
            }
        };

        // Compare all hint types
        compareHint("leaf", treeData.잎_힌트, images);
        compareHint("bark", treeData.수피_힌트, images);
        compareHint("flower", treeData.꽃_힌트, images);
        compareHint("fruit", treeData.열매_힌트, images);
        compareHint("bud", treeData.겨울눈_힌트, images);

        if (changes.length > 0) {
            comparisons.push({
                수목명: treeName,
                tree_id: tree.id,
                changes: changes,
            });
            treesWithChanges++;
        }
    }

    // Save comparison report
    const reportPath = path.resolve(
        __dirname,
        "data/hint_comparison_report.json",
    );
    fs.writeFileSync(reportPath, JSON.stringify(comparisons, null, 2), "utf-8");

    // Generate human-readable summary
    const summaryPath = path.resolve(
        __dirname,
        "data/hint_comparison_summary.txt",
    );
    let summary = "";
    summary += "=".repeat(70) + "\n";
    summary += "🔍 Hint Comparison Report\n";
    summary += "=".repeat(70) + "\n\n";
    summary += `📊 Total trees analyzed: ${catalogData.length}\n`;
    summary += `🔄 Trees with hint changes: ${treesWithChanges}\n`;
    summary += `📝 Total hint changes: ${totalChanges}\n\n`;
    summary += "=".repeat(70) + "\n";
    summary += "📋 Detailed Changes\n";
    summary += "=".repeat(70) + "\n\n";

    comparisons.forEach((comp, index) => {
        summary += `${index + 1}. ${comp.수목명} (ID: ${comp.tree_id})\n`;
        summary += "-".repeat(70) + "\n";

        comp.changes.forEach((change) => {
            summary += `  [${change.image_type.toUpperCase()}] ${change.status}\n`;
            summary += `    Current: "${change.current_hint || "(empty)"}"\n`;
            summary += `    New:     "${change.new_hint || "(empty)"}"\n`;
            summary += "\n";
        });

        summary += "\n";
    });

    fs.writeFileSync(summaryPath, summary, "utf-8");

    console.log("\n" + "=".repeat(70));
    console.log("✅ Step 1 Completed: Comparison Analysis");
    console.log("=".repeat(70));
    console.log(`📊 Total trees analyzed: ${catalogData.length}`);
    console.log(`🔄 Trees with hint changes: ${treesWithChanges}`);
    console.log(`📝 Total hint changes: ${totalChanges}`);
    console.log("\n📁 Files generated:");
    console.log(`  1. ${reportPath}`);
    console.log(`  2. ${summaryPath}`);
    console.log("\n" + "=".repeat(70));
    console.log("📋 Next Step:");
    console.log("  1. Review the comparison files");
    console.log("  2. Run the update script to apply changes");
    console.log("=".repeat(70));
}

compareHints();
