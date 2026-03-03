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

async function findMissingDataHints() {
    console.log("🔍 Searching for '자료없음' in tree_images hints...\n");

    // Get all trees
    const { data: trees, error: treesError } = await supabase
        .from("trees")
        .select("id, name_kr")
        .order("name_kr");

    if (treesError) {
        console.error("❌ Error fetching trees:", treesError);
        process.exit(1);
    }

    const results: any[] = [];

    for (const tree of trees!) {
        // Get all images for this tree
        const { data: images, error: imagesError } = await supabase
            .from("tree_images")
            .select("image_type, hint")
            .eq("tree_id", tree.id);

        if (imagesError) {
            console.error(`❌ Error fetching images for ${tree.name_kr}`);
            continue;
        }

        const missingDataTypes: string[] = [];

        for (const image of images!) {
            if (image.hint && image.hint.includes("자료없음")) {
                missingDataTypes.push(image.image_type);
            }
        }

        if (missingDataTypes.length > 0) {
            results.push({
                수목명: tree.name_kr,
                tree_id: tree.id,
                카테고리: missingDataTypes,
            });
        }
    }

    // Display results
    console.log("=".repeat(70));
    console.log("📋 '자료없음' 포함된 힌트 목록");
    console.log("=".repeat(70));
    console.log(`\n총 수목 수: ${results.length}개\n`);

    let totalMissingData = 0;

    results.forEach((result, index) => {
        console.log(`${index + 1}. ${result.수목명} (ID: ${result.tree_id})`);
        console.log(`   카테고리: ${result.카테고리.join(", ")}`);
        totalMissingData += result.카테고리.length;
    });

    console.log("\n" + "=".repeat(70));
    console.log(`📊 총 '자료없음' 항목 수: ${totalMissingData}개`);
    console.log("=".repeat(70));

    // Save to file
    const reportPath = path.resolve(
        __dirname,
        "data/missing_data_hints_report.json",
    );
    fs.writeFileSync(reportPath, JSON.stringify(results, null, 2), "utf-8");

    console.log(`\n✅ Report saved to: ${reportPath}`);

    // Generate summary by category
    const categoryCount: { [key: string]: number } = {};

    results.forEach((result) => {
        result.카테고리.forEach((category: string) => {
            categoryCount[category] = (categoryCount[category] || 0) + 1;
        });
    });

    console.log("\n" + "=".repeat(70));
    console.log("📊 카테고리별 '자료없음' 통계");
    console.log("=".repeat(70));

    Object.entries(categoryCount)
        .sort((a, b) => b[1] - a[1])
        .forEach(([category, count]) => {
            console.log(`  ${category}: ${count}개`);
        });

    console.log("=".repeat(70));
}

findMissingDataHints();
