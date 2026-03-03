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

async function runMigration() {
    console.log(
        "🔧 Running migration: Add hint and is_quiz_enabled to tree_images\n",
    );

    try {
        // Step 1: Add columns
        console.log("📝 Step 1: Adding columns...");
        const { error: alterError } = await supabase.rpc("exec_sql", {
            sql: `
                ALTER TABLE public.tree_images 
                ADD COLUMN IF NOT EXISTS hint text,
                ADD COLUMN IF NOT EXISTS is_quiz_enabled boolean DEFAULT true NOT NULL;
            `,
        });

        if (alterError) {
            // Try alternative approach using raw SQL
            console.log("⚠️  RPC method not available, using direct query...");

            // Note: Supabase client doesn't support DDL directly
            // User needs to run this in SQL Editor
            console.log("\n❌ Cannot run DDL through Supabase client.");
            console.log(
                "\n📋 Please run the following SQL in Supabase SQL Editor:",
            );
            console.log("\n" + "=".repeat(70));
            console.log(`
ALTER TABLE public.tree_images 
  ADD COLUMN IF NOT EXISTS hint text,
  ADD COLUMN IF NOT EXISTS is_quiz_enabled boolean DEFAULT true NOT NULL;

UPDATE public.tree_images 
SET is_quiz_enabled = true 
WHERE is_quiz_enabled IS NULL;
            `);
            console.log("=".repeat(70));
            process.exit(1);
        }

        console.log("✅ Columns added successfully");

        // Step 2: Update existing records
        console.log("\n📝 Step 2: Setting default values...");
        const { error: updateError } = await supabase
            .from("tree_images")
            .update({ is_quiz_enabled: true })
            .is("is_quiz_enabled", null);

        if (updateError) {
            console.log("⚠️  Update warning:", updateError.message);
        } else {
            console.log("✅ Default values set");
        }

        console.log("\n🎉 Migration completed successfully!");
    } catch (e) {
        console.error("❌ Migration failed:", e);
        process.exit(1);
    }
}

runMigration();
