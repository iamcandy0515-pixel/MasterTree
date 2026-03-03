import { supabase } from "./config/supabaseClient";
import dotenv from "dotenv";
dotenv.config();

async function diagnose() {
    console.log("--- Diagnosing quiz_sessions table ---");

    // 1. Try to fetch one row with all columns
    const { data: rows, error: fetchErr } = await supabase
        .from("quiz_sessions")
        .select("*")
        .limit(1);

    if (fetchErr) {
        console.error("Fetch error:", fetchErr);
    } else if (rows && rows.length > 0) {
        console.log("Found a row! Columns:", Object.keys(rows[0]));
        console.log("Row sample:", rows[0]);
    } else {
        console.log(
            "Table is empty. Trying to insert a dummy row with only user_id...",
        );
        // Use a dummy UUID
        const dummyId = "00000000-0000-0000-0000-000000000000";
        const { data: inserted, error: insErr } = await supabase
            .from("quiz_sessions")
            .insert({ user_id: dummyId })
            .select("*")
            .single();

        if (insErr) {
            console.error("Insert error (this might reveal columns):", insErr);
        } else {
            console.log("Inserted! Columns:", Object.keys(inserted));
            console.log("Full data:", inserted);
            // Delete it afterwards
            await supabase.from("quiz_sessions").delete().eq("id", inserted.id);
        }
    }
}

diagnose();
