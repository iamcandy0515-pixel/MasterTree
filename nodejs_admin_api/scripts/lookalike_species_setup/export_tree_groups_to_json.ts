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

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function exportTreeGroups() {
    console.log("🔍 Fetching tree groups from DB...");

    // 1. Fetch Groups
    let { data: groups, error: groupErr } = await supabase
        .from("tree_groups")
        .select("*")
        .order("created_at", { ascending: true });

    if (groupErr) {
        console.error("Error fetching groups:", groupErr);
        return;
    }

    if (!groups || groups.length === 0) {
        console.log("⚠️ No groups found in DB.");
        return;
    }

    // 2. Fetch Members with Tree Info
    const { data: members, error: memberErr } = await supabase
        .from("tree_group_members")
        .select(
            `
            group_id,
            tree_id,
            key_characteristics,
            trees (
                id,
                name_kr
            )
        `,
        );

    if (memberErr) {
        console.error("❌ Error fetching members:", memberErr);
        return;
    }

    // 3. Construct JSON
    const exportData = groups.map((g: any) => {
        // Handle both 'group_name' and 'name' logic
        const gName = g.group_name || g.name;

        // Filter members for this group
        const groupMembers = (members as any[])
            .filter((m) => m.group_id === g.id)
            .map((m) => {
                // Ensure tree is accessed correctly (single object or array)
                const tree = Array.isArray(m.trees) ? m.trees[0] : m.trees;
                return {
                    tree_id: tree?.id, // Keep the real DB ID
                    tree_name: tree?.name_kr,
                    key_characteristics: m.key_characteristics,
                };
            });

        return {
            group_name: gName,
            description: g.description,
            members: groupMembers,
        };
    });

    // 4. Write to data.json
    const outputPath = path.resolve(__dirname, "data.json");
    fs.writeFileSync(outputPath, JSON.stringify(exportData, null, 2), "utf-8");

    console.log(`✅ Exported ${exportData.length} groups to ${outputPath}`);
}

exportTreeGroups();
