import dotenv from "dotenv";
import path from "path";
import fs from "fs";
import { parse } from "csv-parse/sync";
import { createClient } from "@supabase/supabase-js";

dotenv.config();

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function batchUpdateCategories() {
    const csvPath = path.join(
        __dirname,
        "../tree_category_update_template.csv",
    );

    if (!fs.existsSync(csvPath)) {
        console.error("❌ CSV file not found at:", csvPath);
        return;
    }

    const fileContent = fs.readFileSync(csvPath, "utf-8");
    const records = parse(fileContent, {
        columns: true,
        skip_empty_lines: true,
    }) as any[];

    console.log(`🚀 Starting batch update for ${records.length} trees...`);

    let successCount = 0;
    let errorCount = 0;

    for (const record of records) {
        const { id, name_kr, new_category } = record;

        if (!id || !new_category) {
            console.warn(
                `⚠️ Skipping row with missing data: ID=${id}, Name=${name_kr}`,
            );
            continue;
        }

        const { error } = await supabase
            .from("trees")
            .update({ category: new_category.trim() })
            .eq("id", id);

        if (error) {
            console.error(
                `❌ Failed to update ID ${id} (${name_kr}):`,
                error.message,
            );
            errorCount++;
        } else {
            successCount++;
        }
    }

    console.log(`\n✅ Update Complete!`);
    console.log(`- Success: ${successCount}`);
    console.log(`- Failed: ${errorCount}`);
}

batchUpdateCategories();
