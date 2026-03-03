import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";
import fs from "fs";

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function resetAndImport() {
    console.log("🔥 Resetting Tree Groups...");

    // 1. Delete all groups (Cascades to members)
    const { error: delErr } = await supabase
        .from("tree_groups")
        .delete()
        .neq("id", 0); // Delete all (assuming ID sequence starts at 1)

    if (delErr) {
        console.error("❌ Failed to clear groups:", delErr);
        return;
    }
    console.log("✅ Cleared existing groups.");

    // 2. Import Logic
    const dataPath = path.resolve(__dirname, "data.json");
    const rawData = fs.readFileSync(dataPath, "utf-8");
    const groups = JSON.parse(rawData);

    // Fetch tree map
    const { data: trees } = await supabase.from("trees").select("id, name_kr");
    if (!trees) return;
    const treeMap = new Map<string, number>();
    trees.forEach((t) => treeMap.set(t.name_kr.replace(/\s+/g, ""), t.id));

    console.log(`🚀 Importing ${groups.length} groups...`);

    let successCount = 0;
    for (const group of groups) {
        // Use 'group_name' column as per recent schema change
        const { data: newGroup, error: insErr } = await supabase
            .from("tree_groups")
            .insert([
                {
                    group_name: group.group_name, // Renamed column
                    description: group.description,
                },
            ])
            .select()
            .single();

        if (insErr) {
            console.error(
                `❌ Failed to insert group ${group.group_name}:`,
                insErr,
            );
            continue;
        }

        const groupId = newGroup.id;

        if (group.members && group.members.length > 0) {
            const membersPayload = group.members
                .map((m: any) => {
                    const tid = treeMap.get(m.tree_name.replace(/\s+/g, ""));
                    if (!tid)
                        console.warn(`   ⚠️ Tree not found: ${m.tree_name}`);
                    return {
                        group_id: groupId,
                        tree_id: tid,
                        key_characteristics: m.key_characteristics,
                    };
                })
                .filter((m: any) => m.tree_id);

            if (membersPayload.length > 0) {
                await supabase
                    .from("tree_group_members")
                    .insert(membersPayload);
            }
        }
        successCount++;
    }
    console.log(`🎉 Import finished! Imported ${successCount} groups.`);
}

resetAndImport();
