import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL || "";
const SUPABASE_KEY = process.env.SUPABASE_KEY || "";

if (!SUPABASE_URL || !SUPABASE_KEY) {
    console.error("Missing SUPABASE_URL or SUPABASE_KEY in .env");
    process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function runMigration() {
    console.log("Starting DB Migration for 'app_settings' table...");

    const { error } = await supabase.rpc("create_settings_table_if_not_exists");

    if (error) {
        // If RPC doesn't exist, try direct SQL execution if possible (only via Service Key)
        // However, Supabase client by default doesn't support raw SQL query execution for security.
        // But we can use the 'app_settings' create table logic via PostgREST if we implement a function.

        // Fallback: Use standard JS logic to check and create if table creation API is exposed,
        // but typically standard client cannot CREATE TABLE.

        console.warn(
            "RPC method failed or not found. Attempting alternative method...",
        );
        console.warn(
            "Note: Supabase JS Client cannot run arbitrary SQL unless via RPC.",
        );
        console.warn(
            "Please run the following SQL in your Supabase SQL Editor:",
        );
        console.log(`
---------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

INSERT INTO public.app_settings (key, value, description)
VALUES ('entry_code', '1234', '앱 입장 코드')
ON CONFLICT (key) DO NOTHING;
---------------------------------------------------
        `);
        return;
    }

    console.log("Migration completed successfully via RPC.");
}

// Since we cannot easily execute RAW SQL from the client without an RPC function,
// We will guide the user to run the SQL, OR we can try to use a specific admin library if available.
// However, given the environment, printing the SQL is the safest approach if we don't have direct DB access.

runMigration();
