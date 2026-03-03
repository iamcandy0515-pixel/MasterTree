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

async function checkEmptyHints() {
    console.log("🔍 Checking for empty hints in tree_images...\n");

    // Get all images
    const { data: allImages, error: allError } = await supabase
        .from("tree_images")
        .select(
            `
            id,
            tree_id,
            image_type,
            hint,
            is_quiz_enabled,
            trees (name_kr)
        `,
        )
        .order("tree_id", { ascending: true })
        .order("image_type", { ascending: true });

    if (allError) {
        console.error("❌ Error fetching images:", allError.message);
        process.exit(1);
    }

    console.log(`📊 Total images in database: ${allImages?.length || 0}\n`);

    // Separate images with and without hints
    const imagesWithHints =
        allImages?.filter((img: any) => img.hint && img.hint.trim() !== "") ||
        [];
    const imagesWithoutHints =
        allImages?.filter((img: any) => !img.hint || img.hint.trim() === "") ||
        [];

    console.log("=".repeat(70));
    console.log("📊 Summary");
    console.log("=".repeat(70));
    console.log(`✅ Images with hints: ${imagesWithHints.length}`);
    console.log(`📭 Images without hints: ${imagesWithoutHints.length}`);
    console.log("=".repeat(70));

    if (imagesWithoutHints.length > 0) {
        console.log("\n📭 Images WITHOUT Hints:");
        console.log("=".repeat(70));

        // Group by tree
        const groupedByTree: Record<string, any[]> = {};
        imagesWithoutHints.forEach((img: any) => {
            const treeName = img.trees.name_kr;
            if (!groupedByTree[treeName]) {
                groupedByTree[treeName] = [];
            }
            groupedByTree[treeName].push(img);
        });

        Object.entries(groupedByTree).forEach(([treeName, images]) => {
            console.log(`\n🌲 ${treeName} (ID: ${images[0].tree_id})`);
            console.log("-".repeat(70));
            images.forEach((img: any) => {
                console.log(
                    `  [${img.image_type.toUpperCase()}] hint: "${img.hint || "(empty)"}" | quiz_enabled: ${img.is_quiz_enabled}`,
                );
            });
        });

        // Save to file
        const reportPath = path.resolve(
            __dirname,
            "data/empty_hints_report.txt",
        );
        let report = "";
        report += "=".repeat(70) + "\n";
        report += "📭 Images Without Hints Report\n";
        report += "=".repeat(70) + "\n\n";
        report += `Total images without hints: ${imagesWithoutHints.length}\n\n`;
        report += "=".repeat(70) + "\n";
        report += "Details by Tree\n";
        report += "=".repeat(70) + "\n\n";

        Object.entries(groupedByTree).forEach(([treeName, images]) => {
            report += `${treeName} (ID: ${images[0].tree_id})\n`;
            report += "-".repeat(70) + "\n";
            images.forEach((img: any) => {
                report += `  [${img.image_type.toUpperCase()}] hint: "${img.hint || "(empty)"}" | quiz_enabled: ${img.is_quiz_enabled}\n`;
            });
            report += "\n";
        });

        fs.writeFileSync(reportPath, report, "utf-8");
        console.log(`\n\n📁 Report saved to: ${reportPath}`);
    } else {
        console.log("\n✅ All images have hints!");
    }

    // Statistics by image type
    console.log("\n\n=".repeat(70));
    console.log("📊 Statistics by Image Type");
    console.log("=".repeat(70));

    const imageTypes = ["main", "leaf", "bark", "flower", "fruit", "bud"];
    imageTypes.forEach((type) => {
        const total =
            allImages?.filter((img: any) => img.image_type === type).length ||
            0;
        const withHints =
            allImages?.filter(
                (img: any) =>
                    img.image_type === type &&
                    img.hint &&
                    img.hint.trim() !== "",
            ).length || 0;
        const withoutHints = total - withHints;

        console.log(
            `  ${type.padEnd(10)}: ${total} total | ✅ ${withHints} with hints | 📭 ${withoutHints} without hints`,
        );
    });

    console.log("=".repeat(70));
}

checkEmptyHints();
