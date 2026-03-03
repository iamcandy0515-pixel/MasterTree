import * as fs from "fs";
import * as path from "path";

interface HintChange {
    image_type: string;
    current_hint: string | null;
    new_hint: string;
    status: "UPDATE" | "NO_CHANGE" | "NEW";
}

interface TreeHintComparison {
    수목명: string;
    tree_id: number;
    changes: HintChange[];
}

interface DetailImageHint {
    수목명: string;
    tree_id: number;
    잎_힌트?: string;
    수피_힌트?: string;
    꽃_힌트?: string;
    열매_힌트?: string;
    겨울눈_힌트?: string;
}

async function extractDetailImageHints() {
    console.log(
        "📋 Step 1: Extracting detail image hints from comparison report...\n",
    );

    // Load hint_comparison_report.json
    const reportPath = path.resolve(
        __dirname,
        "data/hint_comparison_report.json",
    );

    if (!fs.existsSync(reportPath)) {
        console.error(`❌ Report file not found: ${reportPath}`);
        process.exit(1);
    }

    const rawData = fs.readFileSync(reportPath, "utf-8");
    const comparisons: TreeHintComparison[] = JSON.parse(rawData);

    console.log(`📦 Loaded ${comparisons.length} trees with hint changes\n`);

    const detailHints: DetailImageHint[] = [];

    for (const comp of comparisons) {
        const hint: DetailImageHint = {
            수목명: comp.수목명,
            tree_id: comp.tree_id,
        };

        let hasDetailHints = false;

        comp.changes.forEach((change) => {
            // Skip main image type
            if (change.image_type === "main") {
                return;
            }

            const newHint = change.new_hint?.trim();
            if (!newHint) {
                return;
            }

            hasDetailHints = true;

            switch (change.image_type) {
                case "leaf":
                    hint.잎_힌트 = newHint;
                    break;
                case "bark":
                    hint.수피_힌트 = newHint;
                    break;
                case "flower":
                    hint.꽃_힌트 = newHint;
                    break;
                case "fruit":
                    hint.열매_힌트 = newHint;
                    break;
                case "bud":
                    hint.겨울눈_힌트 = newHint;
                    break;
            }
        });

        if (hasDetailHints) {
            detailHints.push(hint);
        }
    }

    // Save to file
    const outputPath = path.resolve(__dirname, "data/detail_image_hints.json");
    fs.writeFileSync(outputPath, JSON.stringify(detailHints, null, 2), "utf-8");

    console.log("=".repeat(70));
    console.log("✅ Step 1 Completed: Detail Image Hints Extraction");
    console.log("=".repeat(70));
    console.log(`📊 Total trees with detail hints: ${detailHints.length}`);
    console.log(`📁 File saved to: ${outputPath}`);
    console.log("=".repeat(70));

    // Show summary
    console.log("\n📋 Hint Type Summary:");
    let leafCount = 0;
    let barkCount = 0;
    let flowerCount = 0;
    let fruitCount = 0;
    let budCount = 0;

    detailHints.forEach((hint) => {
        if (hint.잎_힌트) leafCount++;
        if (hint.수피_힌트) barkCount++;
        if (hint.꽃_힌트) flowerCount++;
        if (hint.열매_힌트) fruitCount++;
        if (hint.겨울눈_힌트) budCount++;
    });

    console.log(`  - Leaf (잎) hints: ${leafCount}`);
    console.log(`  - Bark (수피) hints: ${barkCount}`);
    console.log(`  - Flower (꽃) hints: ${flowerCount}`);
    console.log(`  - Fruit (열매) hints: ${fruitCount}`);
    console.log(`  - Bud (겨울눈) hints: ${budCount}`);
    console.log("=".repeat(70));
}

extractDetailImageHints();
