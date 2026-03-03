import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

// Load environment variables
const envPath = path.resolve(__dirname, "../.env");
dotenv.config({ path: envPath });

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY!;

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});

async function inspectGroups() {
    console.log("🔍 Checking Tree Groups for '느릅나무'...");

    const { data: groups, error: gError } = await supabase
        .from("tree_groups")
        .select("*")
        .ilike("group_name", "%느릅나무%");

    if (gError) {
        console.error("Error Groups:", gError);
        return;
    }

    if (!groups || groups.length === 0) {
        console.log("No matching groups found.");
        return;
    }

    for (const group of groups) {
        console.log(`\n🌲 Group: ${group.group_name} (${group.id})`);

        const { data: members, error: mError } = await supabase
            .from("tree_group_members")
            .select(
                `
                *,
                trees (
                   id, name_kr
                )
            `,
            )
            .eq("group_id", group.id);

        if (mError) {
            console.error("Error Members:", mError);
        } else {
            console.log(`   Count: ${members?.length}`);
            members.forEach((m) => {
                const treeName = m.trees ? m.trees.name_kr : "Unknown Tree";
                console.log(
                    `   - Member ID: ${m.id}, Tree ID: ${m.tree_id}, Name: ${treeName}, Sort: ${m.sort_order}`,
                );
            });
        }
    }
}

inspectGroups();
