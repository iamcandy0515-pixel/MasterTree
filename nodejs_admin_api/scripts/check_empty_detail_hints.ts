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

async function checkEmptyDetailHints() {
    console.log("🔍 Checking empty detail image hints by tree...\n");

    // Get all trees with their images
    const { data: trees, error: treesError } = await supabase
        .from("trees")
        .select(
            `
            id,
            name_kr,
            category,
            tree_images(image_type, hint, image_url)
        `,
        )
        .order("name_kr", { ascending: true });

    if (treesError) {
        console.error("❌ Error fetching trees:", treesError.message);
        process.exit(1);
    }

    const treesWithEmptyHints: any[] = [];
    let totalEmptyHints = 0;

    trees?.forEach((tree: any) => {
        const emptyHints: string[] = [];

        const imageTypes = ["leaf", "bark", "flower", "fruit", "bud"];

        imageTypes.forEach((type) => {
            const image = tree.tree_images?.find(
                (img: any) => img.image_type === type,
            );

            if (!image || !image.hint || image.hint.trim() === "") {
                emptyHints.push(type);
                totalEmptyHints++;
            }
        });

        if (emptyHints.length > 0) {
            treesWithEmptyHints.push({
                id: tree.id,
                name: tree.name_kr,
                category: tree.category,
                emptyHints: emptyHints,
            });
        }
    });

    console.log("=".repeat(70));
    console.log("📊 SUMMARY");
    console.log("=".repeat(70));
    console.log(`Total trees: ${trees?.length || 0}`);
    console.log(`Trees with empty detail hints: ${treesWithEmptyHints.length}`);
    console.log(`Total empty hint slots: ${totalEmptyHints}`);
    console.log("=".repeat(70));

    if (treesWithEmptyHints.length > 0) {
        console.log("\n📭 Trees with Empty Detail Hints:");
        console.log("=".repeat(70));

        treesWithEmptyHints.forEach((tree, index) => {
            console.log(
                `${(index + 1).toString().padStart(2)}. ${tree.name.padEnd(15)} (ID: ${tree.id.toString().padStart(2)}, ${tree.category || "N/A"})`,
            );
            console.log(`    Empty: ${tree.emptyHints.join(", ")}`);
        });

        // Save to file
        const reportPath = path.resolve(
            __dirname,
            "data/empty_detail_hints_by_tree.txt",
        );
        let report = "";
        report += "=".repeat(70) + "\n";
        report += "📭 Empty Detail Hints Report (By Tree)\n";
        report += "=".repeat(70) + "\n\n";
        report += `Total trees: ${trees?.length || 0}\n`;
        report += `Trees with empty hints: ${treesWithEmptyHints.length}\n`;
        report += `Total empty hint slots: ${totalEmptyHints}\n\n`;
        report += "=".repeat(70) + "\n";
        report += "Trees with Empty Detail Hints\n";
        report += "=".repeat(70) + "\n\n";

        treesWithEmptyHints.forEach((tree, index) => {
            report += `${(index + 1).toString().padStart(2)}. ${tree.name} (ID: ${tree.id}, ${tree.category || "N/A"})\n`;
            report += `    Empty hints: ${tree.emptyHints.join(", ")}\n\n`;
        });

        fs.writeFileSync(reportPath, report, "utf-8");
        console.log(`\n📁 Report saved to: ${reportPath}`);
    } else {
        console.log("\n✅ All trees have complete detail hints!");
    }

    console.log("=".repeat(70));
}

checkEmptyDetailHints();
