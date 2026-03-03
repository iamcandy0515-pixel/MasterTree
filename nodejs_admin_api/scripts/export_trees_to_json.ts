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

interface TreeWithImages {
    id: number;
    name_kr: string;
    scientific_name: string | null;
    description: string | null;
    created_at: string;
    tree_images: Array<{
        image_type: string;
        image_url: string;
        hint: string | null;
        is_quiz_enabled: boolean;
    }>;
}

interface ExportFormat {
    수목명: string;
    학명: string;
    설명: string;
    대표이미지: string;

    잎_힌트: string;
    잎_이미지: string;
    잎_활성화: boolean;

    수피_힌트: string;
    수피_이미지: string;
    수피_활성화: boolean;

    꽃_힌트: string;
    꽃_이미지: string;
    꽃_활성화: boolean;

    열매_힌트: string;
    열매_이미지: string;
    열매_활성화: boolean;

    겨울눈_힌트: string;
    겨울눈_이미지: string;
    겨울눈_활성화: boolean;

    상태: string;
    조회수: number;
    생성일: string;
    수정일: string;
}

async function exportTreesToJson() {
    console.log("📤 Starting database export...\n");

    // Fetch all trees with their images
    const { data: trees, error } = await supabase
        .from("trees")
        .select(
            `
            id,
            name_kr,
            scientific_name,
            description,
            created_at,
            tree_images (
                image_type,
                image_url,
                hint,
                is_quiz_enabled
            )
        `,
        )
        .order("name_kr", { ascending: true });

    if (error) {
        console.error("❌ Error fetching trees:", error.message);
        process.exit(1);
    }

    if (!trees || trees.length === 0) {
        console.log("⚠️  No trees found in database");
        process.exit(0);
    }

    console.log(`📦 Found ${trees.length} trees in database\n`);

    // Transform to export format
    const exportData: ExportFormat[] = trees.map((tree: TreeWithImages) => {
        // Helper function to find image by type
        const findImage = (type: string) => {
            return tree.tree_images?.find((img) => img.image_type === type);
        };

        const mainImage = findImage("main");
        const leafImage = findImage("leaf");
        const barkImage = findImage("bark");
        const flowerImage = findImage("flower");
        const fruitImage = findImage("fruit");
        const budImage = findImage("bud");

        return {
            수목명: tree.name_kr,
            학명: tree.scientific_name || "",
            설명: tree.description || "",
            대표이미지: mainImage?.image_url || "",

            잎_힌트: leafImage?.hint || "",
            잎_이미지: leafImage?.image_url || "",
            잎_활성화: leafImage?.is_quiz_enabled ?? false,

            수피_힌트: barkImage?.hint || "",
            수피_이미지: barkImage?.image_url || "",
            수피_활성화: barkImage?.is_quiz_enabled ?? false,

            꽃_힌트: flowerImage?.hint || "",
            꽃_이미지: flowerImage?.image_url || "",
            꽃_활성화: flowerImage?.is_quiz_enabled ?? false,

            열매_힌트: fruitImage?.hint || "",
            열매_이미지: fruitImage?.image_url || "",
            열매_활성화: fruitImage?.is_quiz_enabled ?? false,

            겨울눈_힌트: budImage?.hint || "",
            겨울눈_이미지: budImage?.image_url || "",
            겨울눈_활성화: budImage?.is_quiz_enabled ?? false,

            상태: "published",
            조회수: 0,
            생성일: tree.created_at,
            수정일: tree.created_at,
        };
    });

    // Write to file
    const outputPath = path.resolve(
        __dirname,
        "data/trees_exported_from_db.json",
    );
    fs.writeFileSync(outputPath, JSON.stringify(exportData, null, 2), "utf-8");

    console.log(`✅ Export completed!`);
    console.log(`📁 File saved to: ${outputPath}`);
    console.log(`📊 Total trees exported: ${exportData.length}`);

    // Statistics
    const withImages = exportData.filter(
        (t) =>
            t.대표이미지 ||
            t.잎_이미지 ||
            t.수피_이미지 ||
            t.꽃_이미지 ||
            t.열매_이미지 ||
            t.겨울눈_이미지,
    ).length;
    const withoutImages = exportData.length - withImages;

    console.log(`\n📸 Trees with images: ${withImages}`);
    console.log(`📭 Trees without images: ${withoutImages}`);
}

exportTreesToJson();
