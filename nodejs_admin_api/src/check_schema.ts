import "./env";
import { supabase } from "./config/supabaseClient";

async function checkSchema() {
    console.log("\n--- 🕵️ Stats Discovery Report ---");

    // 1. Get ALL unique users from quiz_attempts
    const { data: attempts } = await supabase.from("quiz_attempts").select("user_id");
    const uniqueUserIds = Array.from(new Set(attempts?.map(a => a.user_id) || []));

    console.log(`👤 Found ${uniqueUserIds.length} unique users in the database.\n`);

    for (const uid of uniqueUserIds) {
        // [Attempts Summary]
        const { count: aCount } = await supabase.from("quiz_attempts").select("*", { count: "exact", head: true }).eq("user_id", uid);
        // [Summary Table Status]
        const { count: sCount } = await supabase.from("user_quiz_summary" as any).select("*", { count: "exact", head: true }).eq("user_id", uid);
        
        console.log(`>> User [${uid}]`);
        console.log(`   - Raw Attempts: ${aCount} records`);
        console.log(`   - Summary Table: ${sCount} records (This is what the app shows)`);
        console.log("------------------------------------------");
    }

    if (uniqueUserIds.length === 0) {
        console.log("⚠️ No users found in quiz_attempts table. Please check if you have submitted any quizzes.");
    }
}

checkSchema();
