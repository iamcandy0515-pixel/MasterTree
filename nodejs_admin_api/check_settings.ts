import dotenv from "dotenv";
dotenv.config();
import { supabase } from "./src/config/supabaseClient";

async function checkUrl() {
  const { data, error } = await supabase
    .from("app_settings")
    .select("*")
    .in("key", ["exam_drive_url", "google_drive_folder_url"]);

  if (error) {
    console.error("Error fetching settings:", error);
    return;
  }

  console.log("Current Drive Settings:");
  console.log(JSON.stringify(data, null, 2));
}

checkUrl();
