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

async function updateTreeShapes() {
    console.log("🔄 2차: trees 테이블 shape 컬럼 업데이트 중...\n");

    // Load extracted data
    const dataPath = path.resolve(__dirname, "data/tree_shapes_extract.json");

    if (!fs.existsSync(dataPath)) {
        console.error("❌ 파일을 찾을 수 없습니다:", dataPath);
        console.error("먼저 extract_tree_shapes.ts를 실행해주세요.");
        process.exit(1);
    }

    const shapeData: TreeShapeData[] = JSON.parse(
        fs.readFileSync(dataPath, "utf-8"),
    );

    console.log(`📦 로드된 데이터: ${shapeData.length}개\n`);

    let successCount = 0;
    let errorCount = 0;

    for (const item of shapeData) {
        try {
            const { error } = await supabase
                .from("trees")
                .update({ shape: item.shape })
                .eq("id", item.tree_id);

            if (error) {
                console.error(
                    `❌ ${item.수목명} (ID: ${item.tree_id}): 업데이트 실패 -`,
                    error.message,
                );
                errorCount++;
            } else {
                console.log(
                    `✅ ${item.수목명} (ID: ${item.tree_id}): shape = "${item.shape}"`,
                );
                successCount++;
            }
        } catch (e) {
            console.error(
                `❌ ${item.수목명} (ID: ${item.tree_id}): 예외 발생 -`,
                e,
            );
            errorCount++;
        }
    }

    console.log("\n" + "=".repeat(70));
    console.log("📊 업데이트 완료 통계");
    console.log("=".repeat(70));
    console.log(`총 시도: ${shapeData.length}개`);
    console.log(`✅ 성공: ${successCount}개`);
    console.log(`❌ 실패: ${errorCount}개`);
    console.log("=".repeat(70));

    // Verify updates
    console.log("\n🔍 업데이트 검증 중...\n");

    const { data: verifyData, error: verifyError } = await supabase
        .from("trees")
        .select("id, name_kr, shape")
        .not("shape", "is", null);

    if (verifyError) {
        console.error("❌ 검증 실패:", verifyError);
        return;
    }

    console.log(`✅ Shape이 설정된 수목: ${verifyData?.length}개\n`);

    // Show shape distribution
    const shapeCount: { [key: string]: number } = {};
    verifyData?.forEach((tree) => {
        const shape = tree.shape || "미분류";
        shapeCount[shape] = (shapeCount[shape] || 0) + 1;
    });

    console.log("📊 Shape 분포 (DB 최종 상태):");
    Object.entries(shapeCount).forEach(([shape, count]) => {
        console.log(`  ${shape}: ${count}개`);
    });
}

updateTreeShapes();
