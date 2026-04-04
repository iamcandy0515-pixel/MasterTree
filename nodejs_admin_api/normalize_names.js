require("dotenv").config();
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
);

async function normalizeExistingNames() {
    console.log("--- Normalizing existing tree names (Removing spaces) ---");

    // 1. Fetch all
    const { data: allTrees, error } = await supabase
        .from("trees")
        .select("id, name_kr");

    if (error) {
        console.error("Error fetching trees:", error);
        return;
    }

    console.log(`Found ${allTrees.length} trees.`);

    // 2. Map normalized names and check for potential conflicts
    const nameMap = new Map();
    const toUpdate = [];
    const toDelete = [];

    allTrees.forEach((tree) => {
        const normalized = tree.name_kr.replace(/\s+/g, "");
        if (nameMap.has(normalized)) {
            // Already exists! This is a duplicate after normalization.
            console.log(
                `Duplicate detected: ${tree.name_kr} (ID: ${tree.id}) matches existing ${normalized}`,
            );
            toDelete.push(tree.id);
        } else {
            nameMap.set(normalized, tree.id);
            if (tree.name_kr !== normalized) {
                toUpdate.push({ id: tree.id, name_kr: normalized });
            }
        }
    });

    console.log(`${toUpdate.length} trees need name normalization.`);
    console.log(
        `${toDelete.length} trees are duplicates after normalization and will be deleted.`,
    );

    // 3. Update names
    for (const item of toUpdate) {
        const { error: updError } = await supabase
            .from("trees")
            .update({ name_kr: item.name_kr })
            .eq("id", item.id);

        if (updError)
            console.error(`Failed to update ID ${item.id}:`, updError);
        else console.log(`Normalized ID ${item.id} -> ${item.name_kr}`);
    }

    // 4. Delete duplicates
    if (toDelete.length > 0) {
        const { error: delError } = await supabase
            .from("trees")
            .delete()
            .in("id", toDelete);

        if (delError) console.error("Failed to delete duplicates:", delError);
        else console.log(`Deleted ${toDelete.length} duplicate records.`);
    }

    console.log("--- Normalization complete ---");
}

normalizeExistingNames();
