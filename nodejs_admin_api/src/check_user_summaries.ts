import "./env";
import { supabase } from "./config/supabaseClient";

async function checkUserSummaries() {
    console.log("\n--- 📊 User Quiz Summary Grouping Report ---");

    // 1. Get all unique user_ids from user_quiz_summary
    const { data: summaries, error: summaryError } = await supabase
        .from("user_quiz_summary" as any)
        .select("user_id");

    if (summaryError) {
        console.error("Error fetching summaries:", summaryError);
        return;
    }

    if (!summaries || summaries.length === 0) {
        console.log("No data found in user_quiz_summary table.");
        return;
    }

    // Group by user_id
    const userSummaryCounts: Record<string, number> = {};
    summaries.forEach((s: any) => {
        userSummaryCounts[s.user_id] = (userSummaryCounts[s.user_id] || 0) + 1;
    });

    const uniqueUserIds = Object.keys(userSummaryCounts);
    console.log(`👤 Found ${uniqueUserIds.length} users with summary data.\n`);

    // 2. Fetch user details from 'users' table
    // We check both 'id' and 'auth_id' as references might vary
    const { data: users, error: userError } = await supabase
        .from("users")
        .select("id, auth_id, email, name, status")
        .or(`id.in.(${uniqueUserIds.map(id => `"${id}"`).join(",")}),auth_id.in.(${uniqueUserIds.map(id => `"${id}"`).join(",")})`);

    if (userError) {
        console.error("Error fetching user details:", userError);
    }

    const userMap = new Map();
    users?.forEach(u => {
        if (u.auth_id) userMap.set(u.auth_id, u);
        userMap.set(u.id, u);
    });

    // 3. Print Report
    console.log("Details:");
    console.log("--------------------------------------------------------------------------------");
    console.log(`${"User ID".padEnd(40)} | ${"Name".padEnd(15)} | ${"Email".padEnd(25)} | ${"Count"}`);
    console.log("--------------------------------------------------------------------------------");

    for (const uid of uniqueUserIds) {
        const userInfo = userMap.get(uid);
        const name = userInfo?.name || "Unknown";
        const email = userInfo?.email || "N/A";
        const count = userSummaryCounts[uid];
        
        console.log(`${uid.padEnd(40)} | ${name.padEnd(15)} | ${email.padEnd(25)} | ${count}`);
    }
    console.log("--------------------------------------------------------------------------------");
}

checkUserSummaries();
