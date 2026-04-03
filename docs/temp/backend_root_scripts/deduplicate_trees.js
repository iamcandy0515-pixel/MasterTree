require("dotenv").config();
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
);

async function deduplicate() {
    console.log('Starting deduplication for "가문비 나무"...');

    // 1. Fetch all trees with name like '가문비%'
    const { data: trees, error } = await supabase
        .from("trees")
        .select("*")
        .ilike("name_kr", "%가문비%")
        .order("id", { ascending: true }); // Oldest first

    if (error) {
        console.error("Error fetching trees:", error);
        return;
    }

    if (!trees || trees.length === 0) {
        console.log("No trees found.");
        return;
    }

    console.log(`Found ${trees.length} trees.`);

    // 2. Identify duplicates targeting '가문비나무' (normalized)
    // We want to merge all into the first one.
    const masterTree = trees[0];
    const slaveTrees = trees.slice(1);

    console.log(`Master Tree: ID ${masterTree.id} (${masterTree.name_kr})`);
    if (slaveTrees.length > 0) {
        console.log(
            `Slave Trees to merge: ${slaveTrees.map((t) => t.id).join(", ")}`,
        );

        // 3. Update Master Name to '가문비나무' (remove space)
        const newName = "가문비나무";
        if (masterTree.name_kr !== newName) {
            console.log(`Updating Master Name to '${newName}'...`);
            const { error: updateError } = await supabase
                .from("trees")
                .update({ name_kr: newName })
                .eq("id", masterTree.id);

            if (updateError)
                console.error("Error updating master name:", updateError);
            else console.log("Master name updated.");
        }

        // 4. Move images from slaves to master
        const slaveIds = slaveTrees.map((t) => t.id);
        console.log("Moving images...");

        // Note: We need to update tree_images.
        // Supabase update: update tree_images set tree_id = masterTree.id where tree_id in slaveIds
        const { data: movedImages, error: moveError } = await supabase
            .from("tree_images")
            .update({ tree_id: masterTree.id })
            .in("tree_id", slaveIds)
            .select();

        if (moveError) {
            console.error("Error moving images:", moveError);
        } else {
            console.log(
                `Moved ${movedImages.length} images to Master ID ${masterTree.id}.`,
            );
        }

        // 5. Delete slave trees
        console.log("Deleting slave trees...");
        const { error: deleteError } = await supabase
            .from("trees")
            .delete()
            .in("id", slaveIds);

        if (deleteError) {
            console.error("Error deleting slaves:", deleteError);
        } else {
            console.log("Slave trees deleted successfully.");
        }
    } else {
        console.log("No duplicates to merge.");
        // Just normalize the name if needed
        if (masterTree.name_kr === "가문비 나무") {
            console.log(`Updating Single Master Name to '가문비나무'...`);
            await supabase
                .from("trees")
                .update({ name_kr: "가문비나무" })
                .eq("id", masterTree.id);
        }
    }

    console.log("Deduplication complete.");
}

deduplicate();
