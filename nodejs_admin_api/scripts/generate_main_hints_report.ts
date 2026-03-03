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

async function generateDetailedReport() {
    console.log("📊 Generating detailed hint status report...\n");

    // Get all trees with their main image hints
    const { data: trees, error: treesError } = await supabase
        .from("trees")
        .select(
            `
            id,
            name_kr,
            category,
            tree_images!inner(image_type, hint)
        `,
        )
        .eq("tree_images.image_type", "main")
        .order("name_kr", { ascending: true });

    if (treesError) {
        console.error("❌ Error fetching trees:", treesError.message);
        process.exit(1);
    }

    const treesWithHints: any[] = [];
    const treesWithoutHints: any[] = [];

    trees?.forEach((tree: any) => {
        const mainImage = tree.tree_images[0];
        const hasHint = mainImage?.hint && mainImage.hint.trim() !== "";

        if (hasHint) {
            treesWithHints.push({
                id: tree.id,
                name: tree.name_kr,
                category: tree.category,
                hint: mainImage.hint,
            });
        } else {
            treesWithoutHints.push({
                id: tree.id,
                name: tree.name_kr,
                category: tree.category,
            });
        }
    });

    console.log("=".repeat(70));
    console.log("📊 SUMMARY");
    console.log("=".repeat(70));
    console.log(`Total trees: ${trees?.length || 0}`);
    console.log(`✅ Trees with main image hints: ${treesWithHints.length}`);
    console.log(
        `📭 Trees without main image hints: ${treesWithoutHints.length}`,
    );
    console.log("=".repeat(70));

    console.log("\n✅ Trees WITH Main Image Hints:");
    console.log("=".repeat(70));
    treesWithHints.forEach((tree, index) => {
        console.log(
            `${(index + 1).toString().padStart(2)}. ${tree.name.padEnd(15)} (ID: ${tree.id.toString().padStart(2)}, ${tree.category || "N/A"})`,
        );
        console.log(`    "${tree.hint.substring(0, 60)}..."`);
    });

    console.log("\n\n📭 Trees WITHOUT Main Image Hints:");
    console.log("=".repeat(70));
    treesWithoutHints.forEach((tree, index) => {
        console.log(
            `${(index + 1).toString().padStart(2)}. ${tree.name.padEnd(15)} (ID: ${tree.id.toString().padStart(2)}, ${tree.category || "N/A"})`,
        );
    });

    // Save to file
    const reportPath = path.resolve(
        __dirname,
        "data/main_image_hints_status.txt",
    );
    let report = "";
    report += "=".repeat(70) + "\n";
    report += "📊 Main Image Hints Status Report\n";
    report += "=".repeat(70) + "\n\n";
    report += `Total trees: ${trees?.length || 0}\n`;
    report += `✅ Trees with hints: ${treesWithHints.length}\n`;
    report += `📭 Trees without hints: ${treesWithoutHints.length}\n\n`;
    report += "=".repeat(70) + "\n";
    report += "✅ Trees WITH Main Image Hints\n";
    report += "=".repeat(70) + "\n\n";

    treesWithHints.forEach((tree, index) => {
        report += `${(index + 1).toString().padStart(2)}. ${tree.name} (ID: ${tree.id}, ${tree.category || "N/A"})\n`;
        report += `    "${tree.hint}"\n\n`;
    });

    report += "\n" + "=".repeat(70) + "\n";
    report += "📭 Trees WITHOUT Main Image Hints\n";
    report += "=".repeat(70) + "\n\n";

    treesWithoutHints.forEach((tree, index) => {
        report += `${(index + 1).toString().padStart(2)}. ${tree.name} (ID: ${tree.id}, ${tree.category || "N/A"})\n`;
    });

    fs.writeFileSync(reportPath, report, "utf-8");

    console.log(`\n\n📁 Report saved to: ${reportPath}`);
    console.log("=".repeat(70));
}

generateDetailedReport();
