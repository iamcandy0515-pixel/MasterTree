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

async function verifyHints() {
    console.log("🔍 Verifying hint updates...\n");

    // Get all images with hints
    const { data: images, error } = await supabase
        .from("tree_images")
        .select(
            `
            id,
            tree_id,
            image_type,
            hint,
            trees (name_kr)
        `,
        )
        .not("hint", "is", null)
        .order("tree_id", { ascending: true });

    if (error) {
        console.error("❌ Error fetching images:", error.message);
        process.exit(1);
    }

    console.log(`📊 Total images with hints: ${images?.length || 0}\n`);

    if (images && images.length > 0) {
        console.log("=".repeat(70));
        console.log("📋 Images with Hints");
        console.log("=".repeat(70));

        let currentTreeId: number | null = null;

        images.forEach((img: any) => {
            if (img.tree_id !== currentTreeId) {
                currentTreeId = img.tree_id;
                console.log(`\n🌲 ${img.trees.name_kr} (ID: ${img.tree_id})`);
                console.log("-".repeat(70));
            }

            console.log(`  [${img.image_type.toUpperCase()}] "${img.hint}"`);
        });

        console.log("\n" + "=".repeat(70));
    } else {
        console.log("⚠️  No images with hints found");
    }

    // Get images without hints
    const { data: emptyImages, error: emptyError } = await supabase
        .from("tree_images")
        .select(
            `
            id,
            tree_id,
            image_type,
            trees (name_kr)
        `,
        )
        .is("hint", null)
        .order("tree_id", { ascending: true });

    if (!emptyError && emptyImages) {
        console.log(`\n📭 Images without hints: ${emptyImages.length}`);
    }
}

verifyHints();
