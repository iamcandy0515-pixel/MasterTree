import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";
import fs from "fs";

dotenv.config({ path: path.resolve(__dirname, "../.env") });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

interface TreeHintTemplate {
    수목명: string;
    tree_id: number;
    대표_힌트?: string;
    잎_힌트?: string;
    수피_힌트?: string;
    꽃_힌트?: string;
    열매_힌트?: string;
    겨울눈_힌트?: string;
    열매와_겨울눈?: {
        열매?: string;
        겨울눈?: string;
    };
}

async function updateTreeHints() {
    const batchFilePath = process.argv[2];
    if (!batchFilePath) {
        console.error(
            "Usage: npx ts-node update_tree_hints_v2.ts <path_to_json>",
        );
        process.exit(1);
    }

    const absolutePath = path.resolve(batchFilePath);
    if (!fs.existsSync(absolutePath)) {
        console.error(`File not found: ${absolutePath}`);
        process.exit(1);
    }

    const template: TreeHintTemplate[] = JSON.parse(
        fs.readFileSync(absolutePath, "utf-8"),
    );

    console.log(`🚀 Starting batch update for ${template.length} trees...\n`);

    for (const item of template) {
        console.log(`🌲 Processing: ${item.수목명} (ID: ${item.tree_id})`);

        // Resolve fruit and bud hints (support both flat and nested keys)
        let fruitPart = item.열매_힌트 || item.열매와_겨울눈?.열매;
        let budPart = item.겨울눈_힌트 || item.열매와_겨울눈?.겨울눈;

        let finalFruitHint = fruitPart || "";

        // If new fruit hint is not provided but bud hint is, fetch existing fruit hint from DB to merge
        if (!fruitPart && budPart) {
            const { data: currentFruit } = await supabase
                .from("tree_images")
                .select("hint")
                .eq("tree_id", item.tree_id)
                .eq("image_type", "fruit")
                .single();

            if (currentFruit?.hint) {
                finalFruitHint = currentFruit.hint;
                console.log(
                    `  ℹ️  Using existing fruit hint from DB for merging`,
                );
            }
        }

        if (budPart) {
            finalFruitHint = finalFruitHint
                ? `${finalFruitHint} | [겨울눈] ${budPart}`
                : `[겨울눈] ${budPart}`;
        }

        const hintMap: Record<string, string | undefined> = {
            main: item.대표_힌트,
            leaf: item.잎_힌트,
            bark: item.수피_힌트,
            flower: item.꽃_힌트,
            fruit: finalFruitHint || undefined,
        };

        for (const [type, hintValue] of Object.entries(hintMap)) {
            if (!hintValue) continue;

            // Check if entry exists
            const { data: existing, error: fetchError } = await supabase
                .from("tree_images")
                .select("id")
                .eq("tree_id", item.tree_id)
                .eq("image_type", type)
                .single();

            if (fetchError && fetchError.code !== "PGRST116") {
                console.error(
                    `  ❌ Error fetching ${type} for ${item.수목명}:`,
                    fetchError.message,
                );
                continue;
            }

            if (existing) {
                // Update
                const { error: updateError } = await supabase
                    .from("tree_images")
                    .update({ hint: hintValue })
                    .eq("id", existing.id);

                if (updateError) {
                    console.error(
                        `  ❌ Failed to update ${type}:`,
                        updateError.message,
                    );
                } else {
                    console.log(`  ✅ Updated ${type} hint`);
                }
            } else {
                // Insert (optional, but usually images should exist. Let's insert if missing image entry but keep placeholder url)
                console.warn(
                    `  ⚠️  No ${type} image entry found for ${item.수목명}. Creating one with placeholder.`,
                );
                const { error: insertError } = await supabase
                    .from("tree_images")
                    .insert({
                        tree_id: item.tree_id,
                        image_type: type,
                        hint: hintValue,
                        image_url: `https://placehold.co/400x400?text=${encodeURIComponent(item.수목명 + "_" + type)}`,
                        is_quiz_enabled: type !== "main", // Enable quiz for detail images by default
                    });

                if (insertError) {
                    console.error(
                        `  ❌ Failed to insert ${type}:`,
                        insertError.message,
                    );
                } else {
                    console.log(
                        `  ➕ Inserted new ${type} image entry with hint`,
                    );
                }
            }
        }

        // Disable 'bud' (겨울눈) hints as they are now merged into 'fruit'
        const { error: disableBudError } = await supabase
            .from("tree_images")
            .update({ is_quiz_enabled: false })
            .eq("tree_id", item.tree_id)
            .eq("image_type", "bud");

        if (!disableBudError) {
            console.log(`  🚫 Disabled 'bud' (겨울눈) quiz entry`);
        }

        console.log("-".repeat(30));
    }

    console.log("\n✨ Batch update completed!");
}

updateTreeHints();
