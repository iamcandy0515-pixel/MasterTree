import "./env";
import { supabase } from "./config/supabaseClient";
import * as fs from 'fs';
import * as path from 'path';

async function generateUserSummariesReport() {
    console.log("Generating report...");

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

    // 2. Fetch user details from 'users' table
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

    // 3. Generate Markdown content
    let report = "# User Quiz Summary Grouping Report\n\n";
    report += `Found ${uniqueUserIds.length} users with summary data.\n\n`;
    report += "| User ID | Name | Email | Summary Records |\n";
    report += "| :--- | :--- | :--- | :---: |\n";

    for (const uid of uniqueUserIds) {
        const userInfo = userMap.get(uid);
        const name = userInfo?.name || "Unknown";
        const email = userInfo?.email || "N/A";
        const count = userSummaryCounts[uid];
        report += `| \`${uid}\` | ${name} | ${email} | ${count} |\n`;
    }

    // Write to a temporary file first, then it could be read or shown as artifact
    const reportPath = path.join(__dirname, 'user_grouping_report.md');
    fs.writeFileSync(reportPath, report);
    console.log(`Report generated at: ${reportPath}`);
}

generateUserSummariesReport();
