import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(__dirname, "../../.env") });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("❌ Missing Supabase environment variables");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkSettings() {
    const { data, error } = await supabase.from("app_settings").select("*");

    if (error) {
        console.error("Error:", error);
    } else {
        console.log("--- App Settings ---");
        data.forEach((item) => {
            console.log(`${item.key}: ${item.value}`);
        });
    }
}

checkSettings();
