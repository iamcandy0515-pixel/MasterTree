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

async function runMigration() {
    console.log("🔧 Migration: Allow NULL image_url in tree_images table\n");

    try {
        // Read the SQL migration file
        const sqlPath = path.resolve(
            __dirname,
            "../../migrations/allow_null_image_url.sql",
        );

        if (!fs.existsSync(sqlPath)) {
            console.error(`❌ Migration file not found: ${sqlPath}`);
            console.error(
                "\n⚠️  Please run this migration manually in Supabase SQL Editor:",
            );
            console.error(
                "\nALTER TABLE public.tree_images ALTER COLUMN image_url DROP NOT NULL;\n",
            );
            process.exit(1);
        }

        const sqlContent = fs.readFileSync(sqlPath, "utf-8");

        console.log("📋 Migration SQL:");
        console.log("=".repeat(70));
        console.log(sqlContent);
        console.log("=".repeat(70));

        console.log(
            "\n⚠️  IMPORTANT: Supabase client cannot execute DDL statements.",
        );
        console.log(
            "Please execute this migration manually in Supabase SQL Editor:\n",
        );
        console.log("1. Go to Supabase Dashboard → SQL Editor");
        console.log("2. Copy and paste the following SQL:");
        console.log("\n" + "=".repeat(70));
        console.log(
            "ALTER TABLE public.tree_images ALTER COLUMN image_url DROP NOT NULL;",
        );
        console.log("=".repeat(70));
        console.log("\n3. Click 'Run' to execute the migration");
        console.log("\n4. Verify the change by running:");
        console.log("\n" + "=".repeat(70));
        console.log(`SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'tree_images' 
  AND table_schema = 'public'
  AND column_name = 'image_url';`);
        console.log("=".repeat(70));
        console.log("\n5. Expected result: is_nullable should be 'YES'\n");

        // Verify current schema
        console.log("📊 Checking current schema...\n");

        const { data: schemaCheck, error: schemaError } = await supabase
            .from("tree_images")
            .select("image_url")
            .limit(1);

        if (schemaError) {
            console.error("❌ Error checking schema:", schemaError.message);
        } else {
            console.log("✅ tree_images table is accessible");
        }

        console.log("\n💡 After running the migration in Supabase SQL Editor,");
        console.log(
            "   you can update hints without requiring image_url values.\n",
        );
    } catch (e) {
        console.error("❌ Error:", e);
        process.exit(1);
    }
}

runMigration();
