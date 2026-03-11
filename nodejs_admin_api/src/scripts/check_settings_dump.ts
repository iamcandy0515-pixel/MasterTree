import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import path from "path";
import fs from "fs";

dotenv.config({ path: path.resolve(__dirname, "../../.env") });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function checkSettings() {
    const { data, error } = await supabase
        .from("app_settings")
        .select("key, value");
    if (error) {
        console.error("Error fetching settings:", error);
    } else {
        let output = "--- EXACT DB SETTINGS ---\n";
        data.forEach((d) => {
            output += `KEY: ${d.key}\n`;
            output += `VAL: ${d.value}\n`;
            output += `---------------------------\n`;
        });
        fs.writeFileSync("settings_dump.txt", output);
        console.log("Settings dumped to settings_dump.txt");

        // Also print to console but carefully
        data.forEach((d) => {
            console.log(`[${d.key}]: ${d.value}`);
        });
    }
}

checkSettings();
