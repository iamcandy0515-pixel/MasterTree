import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";
import fs from "fs";

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, "../.env") });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});

async function inspectTables() {
    let output = "";

    output += "🔍 Inspecting database tables...\n\n";

    // Get trees table structure
    output += "=".repeat(70) + "\n";
    output += "📊 TABLE: trees\n";
    output += "=".repeat(70) + "\n";

    const { data: treesColumns, error: treesError } = await supabase
        .from("trees")
        .select("*")
        .limit(1);

    if (treesError) {
        output += "❌ Error fetching trees: " + treesError.message + "\n";
    } else if (treesColumns && treesColumns.length > 0) {
        const columns = Object.keys(treesColumns[0]);
        output += "\n📋 Columns:\n";
        columns.forEach((col, index) => {
            const value = treesColumns[0][col];
            const type = typeof value;
            output += `  ${index + 1}. ${col} (${type})\n`;
        });

        output += "\n📝 Sample Data:\n";
        output += JSON.stringify(treesColumns[0], null, 2) + "\n";
    }

    // Get tree_images table structure
    output += "\n\n" + "=".repeat(70) + "\n";
    output += "📊 TABLE: tree_images\n";
    output += "=".repeat(70) + "\n";

    const { data: imagesColumns, error: imagesError } = await supabase
        .from("tree_images")
        .select("*")
        .limit(1);

    if (imagesError) {
        output +=
            "❌ Error fetching tree_images: " + imagesError.message + "\n";
    } else if (imagesColumns && imagesColumns.length > 0) {
        const columns = Object.keys(imagesColumns[0]);
        output += "\n📋 Columns:\n";
        columns.forEach((col, index) => {
            const value = imagesColumns[0][col];
            const type = typeof value;
            output += `  ${index + 1}. ${col} (${type})\n`;
        });

        output += "\n📝 Sample Data:\n";
        output += JSON.stringify(imagesColumns[0], null, 2) + "\n";
    } else {
        output += "\n⚠️  No data found in tree_images table\n";
    }

    // Get counts
    output += "\n\n" + "=".repeat(70) + "\n";
    output += "📈 TABLE STATISTICS\n";
    output += "=".repeat(70) + "\n";

    const { count: treesCount } = await supabase
        .from("trees")
        .select("*", { count: "exact", head: true });

    const { count: imagesCount } = await supabase
        .from("tree_images")
        .select("*", { count: "exact", head: true });

    output += `\n📊 trees: ${treesCount} rows\n`;
    output += `📸 tree_images: ${imagesCount} rows\n`;

    // Write to file
    const outputPath = path.resolve(__dirname, "table_inspection.txt");
    fs.writeFileSync(outputPath, output, "utf-8");

    console.log(output);
    console.log(`\n✅ Output saved to: ${outputPath}`);
}

inspectTables();
