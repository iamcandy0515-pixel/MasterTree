import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";
import fs from "fs";

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function auditTrees() {
    console.log("Fetching trees...");
    const { data: trees, error } = await supabase
        .from("trees")
        .select("id, name_kr, category")
        .order("name_kr");

    if (error) {
        console.error("Error fetching trees:", error);
        process.exit(1);
    }

    const lines = [
        `Total trees found: ${trees.length}`,
        "--------------------------------------------------",
        "ID | Name (KR) | Category",
        "--------------------------------------------------",
    ];

    trees.forEach((tree) => {
        lines.push(`${tree.id} | ${tree.name_kr} | ${tree.category}`);
    });

    fs.writeFileSync("audit_output.txt", lines.join("\n"), "utf8");
    console.log("Audit completed. Output written to audit_output.txt");
}

auditTrees();
