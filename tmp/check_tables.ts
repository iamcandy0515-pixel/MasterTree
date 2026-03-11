import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, "../nodejs_admin_api/.env") });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkTables() {
    const tables = [
        "trees",
        "quiz_questions",
        "quiz_exams",
        "quiz_attempts",
        "tree_groups",
        "app_settings",
        "users"
    ];

    console.log("Checking tables...");
    for (const table of tables) {
        const { data, error, count } = await supabase
            .from(table)
            .select("*", { count: "exact", head: true });

        if (error) {
            console.log(`❌ ${table}: Error ${error.code} - ${error.message} (${error.details})`);
        } else {
            console.log(`✅ ${table}: ${count} rows`);
        }
    }
}

checkTables();
