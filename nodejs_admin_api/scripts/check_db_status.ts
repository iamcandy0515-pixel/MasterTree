import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

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

async function checkData() {
    console.log("🔍 Checking database status...\n");

    try {
        // Check trees count
        const { count: treeCount, error: treeError } = await supabase
            .from("trees")
            .select("*", { count: "exact", head: true });

        if (treeError) {
            console.error("❌ Error checking trees:", treeError.message);
        } else {
            console.log(`📊 Total trees in database: ${treeCount}`);
        }

        // Check tree_images count
        const { count: imageCount, error: imageError } = await supabase
            .from("tree_images")
            .select("*", { count: "exact", head: true });

        if (imageError) {
            console.error("❌ Error checking images:", imageError.message);
        } else {
            console.log(`📸 Total images in database: ${imageCount}`);
        }

        // Get sample trees with images
        const { data: sampleTrees, error: sampleError } = await supabase
            .from("trees")
            .select("id, name_kr, category, difficulty")
            .order("name_kr", { ascending: true })
            .limit(10);

        if (sampleError) {
            console.error("❌ Error fetching sample:", sampleError.message);
        } else {
            console.log("\n📋 Sample trees (first 10):");
            sampleTrees?.forEach((tree) => {
                console.log(
                    `  - ${tree.name_kr} (ID: ${tree.id}, Category: ${tree.category || "N/A"}, Difficulty: ${tree.difficulty})`,
                );
            });
        }

        // Check image distribution
        const { data: imageStats, error: statsError } = await supabase
            .from("tree_images")
            .select("image_type")
            .limit(1000);

        if (!statsError && imageStats) {
            const typeCounts: Record<string, number> = {};
            imageStats.forEach((img: { image_type: string }) => {
                typeCounts[img.image_type] =
                    (typeCounts[img.image_type] || 0) + 1;
            });

            console.log("\n📊 Image type distribution:");
            Object.entries(typeCounts).forEach(([type, count]) => {
                console.log(`  - ${type}: ${count}`);
            });
        }
    } catch (e) {
        console.error("❌ Error:", e);
        process.exit(1);
    }
}

checkData();
