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

async function importTreeGroups() {
    const dataPath = path.resolve(__dirname, "data.json");

    if (!fs.existsSync(dataPath)) {
        console.error("❌ Template file not found:", dataPath);
        process.exit(1);
    }

    const rawData = fs.readFileSync(dataPath, "utf-8");
    const groups = JSON.parse(rawData);

    console.log("🔍 Fetching existing trees for ID mapping...");
    const { data: trees, error: treeErr } = await supabase
        .from("trees")
        .select("id, name_kr");

    if (treeErr || !trees) {
        console.error("❌ Failed to fetch trees:", treeErr);
        return;
    }

    const treeMap = new Map<string, number>();
    trees.forEach((t) => treeMap.set(t.name_kr.replace(/\s+/g, ""), t.id));

    console.log(`🚀 Starting import of ${groups.length} tree groups...`);

    // optional: Clear existing groups to avoid duplication if re-running
    // await supabase.from('tree_groups').delete().neq('id', '00000000-0000-0000-0000-000000000000');

    let successCount = 0;
    let failCount = 0;

    for (const group of groups) {
        try {
            console.log(`\n📦 Processing group: ${group.group_name}`);

            // 1. Create Tree Group
            const { data: groupData, error: groupError } = await supabase
                .from("tree_groups")
                .insert([
                    {
                        group_name: group.group_name,
                        description: group.description,
                    },
                ])
                .select()
                .single();

            if (groupError) {
                // If unique constraint error, maybe try to fetch existing?
                if (groupError.code === "23505") {
                    console.log(
                        `   ⚠️ Group already exists: ${group.group_name}. Skipping.`,
                    );
                    failCount++;
                    continue;
                }
                throw new Error(
                    `Failed to create group: ${groupError.message}`,
                );
            }

            const groupId = groupData.id;
            console.log(`   ✅ Group created (ID: ${groupId})`);

            // 2. Add Members
            if (group.members && group.members.length > 0) {
                const membersPayload: any[] = [];

                for (const member of group.members) {
                    const normalizedName = member.tree_name.replace(/\s+/g, "");
                    const actualId = treeMap.get(normalizedName);

                    if (!actualId) {
                        console.warn(
                            `   ⚠️ Warning: Tree '${member.tree_name}' not found in DB. Skipping member.`,
                        );
                        continue;
                    }

                    membersPayload.push({
                        group_id: groupId,
                        tree_id: actualId,
                        // display_order: membersPayload.length + 1,
                        key_characteristics: member.key_characteristics,
                    });
                }

                if (membersPayload.length > 0) {
                    const { error: memberError } = await supabase
                        .from("tree_group_members")
                        .insert(membersPayload);

                    if (memberError) {
                        throw new Error(
                            `Failed to add members: ${memberError.message}`,
                        );
                    }
                    console.log(`   ✅ Added ${membersPayload.length} members`);
                }
            }

            successCount++;
        } catch (error: any) {
            console.error(`   ❌ Error: ${error.message}`);
            failCount++;
        }
    }

    console.log("\n---------------------------------------------------");
    console.log(
        `🎉 Import finished! Success: ${successCount}, Failed: ${failCount}`,
    );
}

importTreeGroups();
