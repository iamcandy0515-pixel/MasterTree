import { supabase } from "./config/supabaseClient";
import dotenv from "dotenv";
dotenv.config();

async function checkInsert() {
    console.log("--- Inserting Dummy Session ---");
    // Get a real user ID from quiz_attempts or somewhere, or just use a dummy one
    const userId = "0e3640ce-4e00-4e65-9910-951b423dc574"; // Just a dummy UUID-like string

    const { data, error } = await supabase
        .from("quiz_sessions")
        .insert({
            user_id: userId,
            session_type: "random",
        })
        .select("*")
        .single();

    if (error) {
        console.error("Insert error:", error);
    } else {
        console.log("Inserted session:", data);
        console.log("Columns discovered:", Object.keys(data));
    }
}

checkInsert();
