require("dotenv").config();
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
);

async function migrate_data() {
    console.log("--- Step 1: Checking current schema ---");
    const { data: sample, error } = await supabase
        .from("trees")
        .select("*")
        .limit(1);

    if (error) {
        console.error("Error fetching sample:", error);
        return;
    }

    if (sample && sample.length > 0) {
        console.log("Original fields:", Object.keys(sample[0]));
    } else {
        console.log("No data found to inspect schema.");
    }

    console.log(
        "\n--- Step 2: Since we cannot run DDL (ALTER TABLE) via JS Client directly, ---",
    );
    console.log(
        "--- We will implement strict logical enforcement in the API service layer. ---",
    );
    console.log(
        '--- And we will update existing rows with category info if "category" column exists. ---',
    );

    // Check if 'category' column exists?
    // If not, we can't update it.
    // The user asked to "review the method of separating".

    // Proposal:
    // 1. Rename 'trees' table to 'species' (conceptually) => No, keep 'trees'.
    // 2. Add 'category' column to 'trees' in Supabase Dashboard (User Action Required).
    // 3. Add Unique Constraint on 'name_kr' in Supabase Dashboard (User Action Required).

    console.log("\n--- Simulation: Categorizing existing trees ---");
    const { data: allTrees } = await supabase
        .from("trees")
        .select("id, name_kr, description");

    if (allTrees) {
        let coniferCount = 0;
        let broadleafCount = 0;

        allTrees.forEach((tree) => {
            const desc = (tree.description || "").toLowerCase();
            const name = tree.name_kr;
            let category = "기타";

            if (
                desc.includes("침엽수") ||
                name.includes("소나무") ||
                name.includes("잣나무") ||
                name.includes("전나무") ||
                name.includes("가문비") ||
                name.includes("측백") ||
                name.includes("향나무") ||
                name.includes("주목") ||
                name.includes("비자나무")
            ) {
                category = "침엽수";
                coniferCount++;
            } else {
                // Default to broadleaf for now if not conifer?
                // Most Korean trees in this list seem to be broadleaf if not conifer.
                category = "활엽수";
                broadleafCount++;
            }
            // console.log(`Tree: ${name} -> ${category}`);
        });

        console.log(
            `Estimated: Conifers: ${coniferCount}, Broadleaf: ${broadleafCount}`,
        );
    }
}

migrate_data();
