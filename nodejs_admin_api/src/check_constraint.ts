import "./env";
import { supabase } from "./config/supabaseClient";
import dotenv from "dotenv";
dotenv.config();

async function checkConstraint() {
    console.log("Fetching constraint info for quiz_sessions...");
    const { data: res, error } = await (supabase as any).rpc("exec_sql", {
        sql_string: `
            SELECT conname, pg_get_constraintdef(c.oid)
            FROM pg_constraint c
            JOIN pg_class t ON t.oid = c.conrelid
            WHERE t.relname = 'quiz_sessions' AND conname = 'quiz_sessions_mode_check';
        `
    });

    if (error) {
        console.error("Error fetching constraint:", error.message);
    } else {
        console.log("Constraint info:", res);
    }
}

checkConstraint();
