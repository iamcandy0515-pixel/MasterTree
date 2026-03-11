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
        console.error("Error fetching settings:", error);
    } else {
        console.log("--- TARGET SETTINGS ---");
        const quiz = data.find((d) => d.key === "google_drive_folder_url");
        const tree = data.find((d) => d.key === "tree_image_drive_url");

        console.log("QUIZ_KEY: google_drive_folder_url");
        console.log("QUIZ_VAL:", quiz ? quiz.value : "MISSING");
        console.log("---------------------------");
        console.log("TREE_KEY: tree_image_drive_url");
        console.log("TREE_VAL:", tree ? tree.value : "MISSING");
        console.log("---------------------------");
    }
}

checkSettings();
