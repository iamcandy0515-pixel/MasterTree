require("dotenv").config();
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
);

const conifers = [
    "가문비나무",
    "잣나무",
    "곰솔",
    "버지니아소나무",
    "전나무",
    "구상나무",
    "주목",
    "분비나무",
    "낙엽송",
    "비자나무",
    "낙우송",
    "편백",
    "삼나무",
    "향나무",
    "소나무",
    "스트로브잣나무",
    "리기테타소나무",
];

async function updateCategories() {
    console.log("--- Updating Categories ---");

    // 1. Mark Conifers
    console.log(`Marking specified ${conifers.length} trees as 침엽수...`);
    const { data: updatedConifers, error: coniferError } = await supabase
        .from("trees")
        .update({ category: "침엽수" })
        .in("name_kr", conifers)
        .select("id, name_kr");

    if (coniferError) {
        console.error("Error updating conifers:", coniferError);
    } else {
        console.log(`Updated ${updatedConifers.length} trees as 침엽수.`);
    }

    // 2. Mark remaining trees as '활엽수'
    // First, find trees where category is null OR category != '침엽수'
    // Actually, safer to check is null if column was just added.
    // If updating, we should update those NOT in conifer list.

    // Find all IDs
    const { data: allTrees } = await supabase
        .from("trees")
        .select("id, name_kr");
    const coniferNamesSet = new Set(conifers);

    const broadleafIds = allTrees
        .filter((t) => !coniferNamesSet.has(t.name_kr))
        .map((t) => t.id);

    console.log(`Found ${broadleafIds.length} trees to mark as 활엽수.`);

    if (broadleafIds.length > 0) {
        const { error: broadError } = await supabase
            .from("trees")
            .update({ category: "활엽수" })
            .in("id", broadleafIds);

        if (broadError) console.error("Error updating broadleaf:", broadError);
        else console.log("Broadleaf update complete.");
    }
}

updateCategories();
