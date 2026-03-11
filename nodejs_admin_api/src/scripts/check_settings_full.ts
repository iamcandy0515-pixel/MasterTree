import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import path from "path";

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
        console.error(error);
    } else {
        console.log("--- Current DB Settings ---");
        data.forEach((d) => {
            console.log(`Key: ${d.key}`);
            console.log(`Value: ${d.value}`);
            console.log("---------------------------");
        });
    }
}

checkSettings();
