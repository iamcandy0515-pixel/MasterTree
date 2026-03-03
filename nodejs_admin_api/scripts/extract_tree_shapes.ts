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

interface TreeShapeData {
    tree_id: number;
    수목명: string;
    shape: string;
    대표_힌트: string;
}

async function extractTreeShapes() {
    console.log("🔍 1차: tree_images에서 shape 정보 추출 중...\n");

    // Get all trees
    const { data: trees, error: treesError } = await supabase
        .from("trees")
        .select("id, name_kr")
        .order("id");

    if (treesError) {
        console.error("❌ Error fetching trees:", treesError);
        process.exit(1);
    }

    const shapeData: TreeShapeData[] = [];
    let processedCount = 0;
    let foundCount = 0;
    let skippedCount = 0;

    for (const tree of trees!) {
        processedCount++;

        // Get main image hint for this tree
        const { data: image, error: imageError } = await supabase
            .from("tree_images")
            .select("hint")
            .eq("tree_id", tree.id)
            .eq("image_type", "main")
            .maybeSingle();

        if (imageError) {
            console.error(
                `❌ Error fetching image for ${tree.name_kr}:`,
                imageError,
            );
            continue;
        }

        if (!image || !image.hint) {
            console.log(
                `⏭️  ${tree.name_kr} (ID: ${tree.id}): 대표 힌트 없음 - SKIP`,
            );
            skippedCount++;
            continue;
        }

        const hint = image.hint;
        let shape: string | null = null;

        // Check for 상록수 or 낙엽수
        if (hint.includes("상록수")) {
            shape = "상록수";
        } else if (hint.includes("낙엽수")) {
            shape = "낙엽수";
        }

        if (shape) {
            shapeData.push({
                tree_id: tree.id,
                수목명: tree.name_kr,
                shape: shape,
                대표_힌트: hint,
            });
            console.log(`✅ ${tree.name_kr} (ID: ${tree.id}): ${shape}`);
            foundCount++;
        } else {
            console.log(
                `⏭️  ${tree.name_kr} (ID: ${tree.id}): shape 정보 없음 - SKIP`,
            );
            skippedCount++;
        }
    }

    // Save to JSON file
    const outputPath = path.resolve(__dirname, "data/tree_shapes_extract.json");
    fs.writeFileSync(outputPath, JSON.stringify(shapeData, null, 2), "utf-8");

    console.log("\n" + "=".repeat(70));
    console.log("📊 추출 완료 통계");
    console.log("=".repeat(70));
    console.log(`총 처리: ${processedCount}개`);
    console.log(`✅ Shape 발견: ${foundCount}개`);
    console.log(`⏭️  Skip: ${skippedCount}개`);
    console.log("=".repeat(70));
    console.log(`\n✅ 파일 저장: ${outputPath}`);

    // Display shape distribution
    const shapeCount: { [key: string]: number } = {};
    shapeData.forEach((item) => {
        shapeCount[item.shape] = (shapeCount[item.shape] || 0) + 1;
    });

    console.log("\n📊 Shape 분포:");
    Object.entries(shapeCount).forEach(([shape, count]) => {
        console.log(`  ${shape}: ${count}개`);
    });
}

extractTreeShapes();
