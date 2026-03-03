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

async function verifyMigration() {
    console.log("🔍 Verifying migration: NULL image_url support\n");

    try {
        // Test 1: Check if we can insert a record with NULL image_url
        console.log("Test 1: Inserting test record with NULL image_url...");

        const { data: testTree, error: treeError } = await supabase
            .from("trees")
            .select("id")
            .limit(1)
            .single();

        if (treeError || !testTree) {
            console.error("❌ Cannot find test tree");
            process.exit(1);
        }

        const testTreeId = testTree.id;

        // Try to insert with NULL image_url
        const { data: insertTest, error: insertError } = await supabase
            .from("tree_images")
            .insert({
                tree_id: testTreeId,
                image_type: "main",
                image_url: null,
                hint: "TEST: Migration verification - this will be deleted",
                is_quiz_enabled: false,
            })
            .select()
            .single();

        if (insertError) {
            console.error("❌ Migration verification FAILED!");
            console.error("Error:", insertError.message);
            console.error(
                "\nThe migration may not have been applied correctly.",
            );
            process.exit(1);
        }

        console.log("✅ Successfully inserted record with NULL image_url!");
        console.log(`   Record ID: ${insertTest.id}`);

        // Clean up test record
        const { error: deleteError } = await supabase
            .from("tree_images")
            .delete()
            .eq("id", insertTest.id);

        if (deleteError) {
            console.warn(
                "⚠️  Could not delete test record:",
                deleteError.message,
            );
        } else {
            console.log("✅ Test record cleaned up");
        }

        console.log("\n" + "=".repeat(70));
        console.log("🎉 Migration Verification: SUCCESS!");
        console.log("=".repeat(70));
        console.log("✅ image_url can now be NULL");
        console.log("✅ Hints can be stored without actual images");
        console.log("✅ Ready to update remaining 55 trees with hints");
        console.log("=".repeat(70));
    } catch (e) {
        console.error("❌ Unexpected error:", e);
        process.exit(1);
    }
}

verifyMigration();
