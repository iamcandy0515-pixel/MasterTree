import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(__dirname, "../.env") });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkTreeSchema() {
    console.log("🔍 Checking trees table schema and data...\n");

    // Get sample trees
    const { data: trees, error } = await supabase
        .from("trees")
        .select("*")
        .limit(5);

    if (error) {
        console.error("❌ Error:", error);
        process.exit(1);
    }

    console.log("📊 Sample Trees Data:\n");
    console.log(JSON.stringify(trees, null, 2));

    console.log("\n📋 Available Columns:");
    if (trees && trees.length > 0) {
        Object.keys(trees[0]).forEach((key) => {
            console.log(`  - ${key}: ${typeof trees[0][key]}`);
        });
    }

    // Check category distribution
    const { data: allTrees } = await supabase
        .from("trees")
        .select("category, shape");

    if (allTrees) {
        const categoryCount: { [key: string]: number } = {};
        const shapeCount: { [key: string]: number } = {};

        allTrees.forEach((tree) => {
            const cat = tree.category || "미분류";
            const shp = tree.shape || "미분류";
            categoryCount[cat] = (categoryCount[cat] || 0) + 1;
            shapeCount[shp] = (shapeCount[shp] || 0) + 1;
        });

        console.log("\n📊 Category Distribution:");
        Object.entries(categoryCount).forEach(([cat, count]) => {
            console.log(`  ${cat}: ${count}개`);
        });

        console.log("\n📊 Shape Distribution:");
        Object.entries(shapeCount).forEach(([shp, count]) => {
            console.log(`  ${shp}: ${count}개`);
        });
    }
}

checkTreeSchema();
