import "./env";
import { supabase } from "./config/supabaseClient";
import dotenv from "dotenv";
dotenv.config();

async function checkModes() {
    console.log("Checking unique modes in quiz_sessions...");
    const { data: modes, error } = await supabase
        .from("quiz_sessions")
        .select("mode");

    if (error) {
        console.error("Error fetching modes:", error);
    } else {
        const uniqueModes = Array.from(new Set(modes?.map(m => m.mode)));
        console.log("Unique modes found:", uniqueModes);
    }
}

checkModes();
