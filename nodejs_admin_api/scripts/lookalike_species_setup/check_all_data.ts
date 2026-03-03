import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function checkAll() {
    console.log("🔍 Checking Database Content...");

    // 1. Tree Groups
    const {
        count: groupCount,
        error: gErr,
        data: groups,
    } = await supabase.from("tree_groups").select("*", { count: "exact" });

    if (gErr) console.error("Error Groups:", gErr);
    else console.log(`✅ Tree Groups: ${groupCount} rows`);
    if (groups && groups.length > 0) {
        console.log("   Example Group:", JSON.stringify(groups[0], null, 2));
    }

    // 2. Tree Group Members
    const { count: memberCount, error: mErr } = await supabase
        .from("tree_group_members")
        .select("*", { count: "exact", head: true });

    if (mErr) console.error("Error Members:", mErr);
    else console.log(`✅ Tree Group Members: ${memberCount} rows`);
}

checkAll();
