require("dotenv").config();
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
);

(async () => {
    try {
        const { data, error } = await supabase
            .from("trees")
            .select("id, name_kr, created_at")
            .ilike("name_kr", "%가문비%")
            .order("id");

        if (error) {
            console.error("Error fetching trees:", error);
            return;
        }

        const { data: id1 } = await supabase
            .from("trees")
            .select("*")
            .eq("id", 1);
        console.log("ID 1:", id1);

        const tightName = await supabase
            .from("trees")
            .select("*")
            .eq("name_kr", "가문비나무");
        console.log("NoSpace Name:", tightName.data);

        const { data: all } = await supabase.from("trees").select("name_kr");
        const names = all.map((t) => t.name_kr).sort();
        const unique = [...new Set(names)];
        const fs = require("fs");
        fs.writeFileSync("unique_names_list.txt", unique.join("\n"), "utf8");
        console.log(`Written ${unique.length} unique names to file.`);
    } catch (err) {
        console.error("Unexpected error:", err);
    }
})();
