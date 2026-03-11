import dotenv from "dotenv";
import path from "path";
import fs from "fs";
import { createClient } from "@supabase/supabase-js";

dotenv.config();

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function extractCategories() {
    console.log("🚀 Extracting tree categories...");

    const { data, error } = await supabase
        .from("trees")
        .select("id, name_kr, category")
        .order("name_kr", { ascending: true });

    if (error) {
        console.error("❌ Error fetching trees:", error);
        return;
    }

    if (!data || data.length === 0) {
        console.log("⚠️ No trees found.");
        return;
    }

    console.log(`✅ Found ${data.length} trees.`);

    // 1. Markdown Table for documentation
    let mdContent = "# 수목 78종 카테고리 일람표\n\n";
    mdContent +=
        "| ID | 수목명 (한글) | 현재 카테고리 | 신규 카테고리 (수정용) |\n";
    mdContent += "| :--- | :--- | :--- | :--- |\n";

    data.forEach((tree) => {
        mdContent += `| ${tree.id} | ${tree.name_kr} | ${tree.category || ""} | |\n`;
    });

    const mdPath = path.join(__dirname, "../tree_category_report.md");
    fs.writeFileSync(mdPath, mdContent);
    console.log(`📄 Markdown report saved to: ${mdPath}`);

    // 2. CSV Template for Bulk Update
    let csvContent = "id,name_kr,current_category,new_category\n";
    data.forEach((tree) => {
        const escapedCat = (tree.category || "").replace(/"/g, '""');
        csvContent += `${tree.id},${tree.name_kr},"${escapedCat}",${escapedCat}\n`;
    });

    const csvPath = path.join(
        __dirname,
        "../tree_category_update_template.csv",
    );
    fs.writeFileSync(csvPath, csvContent);
    console.log(`📊 CSV Update template saved to: ${csvPath}`);
}

extractCategories();
