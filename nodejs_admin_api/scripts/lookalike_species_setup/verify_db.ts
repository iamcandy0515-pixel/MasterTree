import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";
import fs from "fs";

// Load environment variables
const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
    console.error("❌ Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in .env");
    process.exit(1);
}

// Initialize Supabase client
const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function verifyData() {
    console.log("=== Supabase Data Verification ===");

    // 1. Get Table Counts
    const { count: groupCount, error: groupErr } = await supabase
        .from("tree_groups")
        .select("*", { count: "exact", head: true });

    const { count: memberCount, error: memberErr } = await supabase
        .from("tree_group_members")
        .select("*", { count: "exact", head: true });

    if (groupErr || memberErr) {
        console.error("Error fetching counts:", groupErr || memberErr);
        return;
    }

    console.log(`Table: tree_groups | Count: ${groupCount}`);
    console.log(`Table: tree_group_members | Count: ${memberCount}`);

    // 2. Load data.json
    const dataPath = path.resolve(__dirname, "data.json");
    if (!fs.existsSync(dataPath)) {
        console.error("❌ Template file not found:", dataPath);
        process.exit(1);
    }
    const jsonData = JSON.parse(fs.readFileSync(dataPath, "utf-8"));
    console.log(`JSON: Total Expected Groups: ${jsonData.length}`);

    // 3. Compare Group Names
    const { data: dbGroups } = await supabase
        .from("tree_groups")
        .select("group_name");
    const dbNames = (dbGroups || []).map((g) => g.group_name);
    const missingInDb = jsonData.filter(
        (j: any) => !dbNames.includes(j.group_name),
    );

    console.log("\n--- Verification Result ---");
    if (missingInDb.length === 0 && groupCount === jsonData.length) {
        console.log("✅ Group names match perfectly.");
    } else {
        console.log(`❌ Mismatch detected!`);
        console.log(
            `Groups in JSON: ${jsonData.length}, Groups in DB: ${groupCount}`,
        );
        if (missingInDb.length > 0) {
            console.log(`Groups in JSON but not in DB: ${missingInDb.length}`);
            missingInDb.forEach((m: any) => console.log(` - ${m.group_name}`));
        }
    }

    // 4. Check Tree Existence
    const { count: treesInDb } = await supabase
        .from("trees")
        .select("*", { count: "exact", head: true });
    console.log(`\nTable: trees | Count: ${treesInDb}`);

    if (treesInDb === 0) {
        console.log(
            "⚠️ WARNING: 'trees' table is EMPTY. This is why list might not show names correctly.",
        );
    } else {
        // Sample check for members connectivity
        const { data: members, error: memErr } = await supabase
            .from("tree_group_members")
            .select("*, trees(*)")
            .limit(5);

        console.log("\n--- Connectivity Check (Sample 5 members) ---");
        members?.forEach((m: any) => {
            console.log(
                `Group Member ID: ${m.id} | Tree Link: ${m.trees ? "✅" : "❌"}`,
            );
        });
    }
}

verifyData();
