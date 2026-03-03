/* eslint-disable */
const { createClient } = require("@supabase/supabase-js");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../.env") });

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
);

async function check() {
    console.log("🔍 Checking Data for '느티나무' and '느릅나무'...");

    // 1. Find Trees
    const { data: trees, error } = await supabase
        .from("trees")
        .select("id, name_kr")
        .or("name_kr.ilike.%느티%,name_kr.ilike.%느릅%");

    if (error) {
        console.error(error);
        return;
    }

    if (!trees || trees.length === 0) {
        console.log("No matching trees found.");
        return;
    }

    console.log(
        `✅ Found trees: ${trees.map((t) => `${t.name_kr} (${t.id})`).join(", ")}`,
    );
    const ids = trees.map((t) => t.id);

    // 2. Check Images
    const { data: images } = await supabase
        .from("tree_images")
        .select("tree_id, image_type, hint")
        .in("tree_id", ids);

    console.log(`✅ Found ${images?.length || 0} images.`);

    // Group by tree
    trees.forEach((t) => {
        const treeImages = images?.filter((i) => i.tree_id === t.id) || [];
        console.log(`\n[Tree: ${t.name_kr}]`);
        if (treeImages.length === 0) console.log("  - No images found.");
        treeImages.forEach((img) => {
            console.log(
                `  - ${img.image_type}: Hint="${img.hint || "(NULL)"}"`,
            );
        });
    });
}

check();
