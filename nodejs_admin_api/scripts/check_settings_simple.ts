import * as dotenv from "dotenv";
import path from "path";
dotenv.config({ path: path.resolve(__dirname, "../.env") });
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function checkSettings() {
    const { data, error } = await supabase
        .from("app_settings")
        .select("key, value");
    if (data) {
        data.forEach((row) => {
            console.log(`KEY: ${row.key}`);
            console.log(`VALUE: ${row.value}`);
            console.log("---");
        });
    }
}

checkSettings();
