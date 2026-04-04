import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.join(__dirname, ".env") });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function checkTree(name: string) {
    console.log(`Searching for tree: ${name}...`);

    // 1. Find the tree
    const { data: tree, error: treeError } = await supabase
        .from("trees")
        .select("*")
        .eq("name_kr", name)
        .maybeSingle();

    if (treeError) {
        console.error("Error fetching tree:", treeError);
        return;
    }

    if (!tree) {
        console.log(`Tree '${name}' not found in 'trees' table.`);
        return;
    }

    console.log("Tree found:", JSON.stringify(tree, null, 2));

    // 2. Find images for this tree
    const { data: images, error: imageError } = await supabase
        .from("tree_images")
        .select("*")
        .eq("tree_id", tree.id);

    if (imageError) {
        console.error("Error fetching images:", imageError);
        return;
    }

    console.log(`Found ${images.length} images:`);
    console.log(JSON.stringify(images, null, 2));
}

checkTree("아왜나무");
