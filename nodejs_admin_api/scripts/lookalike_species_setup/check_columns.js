const { createClient } = require("@supabase/supabase-js");
const dotenv = require("dotenv");
const path = require("path");

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;
const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function check() {
    const { data, error } = await supabase
        .from("tree_group_members")
        .select("*")
        .limit(1);
    if (error) {
        console.error("Error:", error);
        return;
    }
    console.log("Columns:", data && data[0] ? Object.keys(data[0]) : "No data");
}

check();
