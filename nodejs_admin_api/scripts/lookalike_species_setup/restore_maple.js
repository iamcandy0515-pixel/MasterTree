const { createClient } = require("@supabase/supabase-js");
const dotenv = require("dotenv");
const path = require("path");

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;
const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function restore() {
    const groupName =
        "단풍나무류 열편 혼동 (단풍나무 vs 당단풍나무 vs 고로쇠나무)";
    const { data: group, error: groupErr } = await supabase
        .from("tree_groups")
        .select("id")
        .ilike("group_name", "단풍나무류 열편 혼동%")
        .single();

    if (groupErr || !group) {
        console.error("Group not found", groupErr);
        return;
    }

    console.log("Found group ID:", group.id);

    const members = [
        {
            group_id: group.id,
            tree_id: 23,
            sort_order: 0,
            key_characteristics: "잎 열편이 깊고 잎이 비교적 얇습니다.",
        },
        {
            group_id: group.id,
            tree_id: 24,
            sort_order: 1,
            key_characteristics:
                "잎이 두껍고 거칠며 털이 있어 단풍나무와 구별됩니다.",
        },
        {
            group_id: group.id,
            tree_id: 25,
            sort_order: 2,
            key_characteristics: "잎이 둥글고 넓으며 수액 채취로 유명합니다.",
        },
    ];

    console.log("Cleaning existing members...");
    await supabase.from("tree_group_members").delete().eq("group_id", group.id);

    console.log(
        "Inserting restored members with correct column name (sort_order)...",
    );
    const { error } = await supabase.from("tree_group_members").insert(members);

    if (error) {
        console.error("Error restoring members:", error);
    } else {
        console.log("✅ Success: Restored 3 members for group:", groupName);
    }
}

restore();
