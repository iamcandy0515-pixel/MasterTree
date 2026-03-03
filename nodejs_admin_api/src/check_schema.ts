import { supabase } from "./config/supabaseClient";
import dotenv from "dotenv";
dotenv.config();

async function checkSchema() {
    console.log("--- Quiz Sessions ---");
    const { data: sessions, error: sErr } = await supabase
        .from("quiz_sessions")
        .select("*")
        .limit(1);
    if (sErr) console.error(sErr);
    else
        console.log(
            "Session columns:",
            Object.keys(sessions[0] || {}),
            sessions[0],
        );

    console.log("--- Quiz Attempts ---");
    const { data: attempts, error: aErr } = await supabase
        .from("quiz_attempts")
        .select("*")
        .limit(1);
    if (aErr) console.error(aErr);
    else
        console.log(
            "Attempt columns:",
            Object.keys(attempts[0] || {}),
            attempts[0],
        );
}

checkSchema();
