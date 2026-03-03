import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.join(process.cwd(), ".env") });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function run() {
    console.log("Fetching trees...");
    const { data: trees, error } = await supabase
        .from("trees")
        .select("id, name_kr");
    if (error) throw error;

    for (const tree of trees) {
        const { data: images } = await supabase
            .from("tree_images")
            .select("*")
            .eq("tree_id", tree.id)
            .in("image_type", ["fruit", "bud", "winter_bud"]);
        if (!images || images.length === 0) continue;

        const fruits = images.filter((i) => i.image_type === "fruit");
        const buds = images.filter(
            (i) => i.image_type === "bud" || i.image_type === "winter_bud",
        );

        if (buds.length > 0) {
            let combinedHint = "";

            // Collect fruit hints
            const fruitHints = Array.from(
                new Set(
                    fruits
                        .map((f) => f.hint)
                        .filter((h) => h && h.trim().length > 0),
                ),
            );
            const budHints = Array.from(
                new Set(
                    buds
                        .map((b) => b.hint)
                        .filter((h) => h && h.trim().length > 0),
                ),
            );

            if (fruitHints.length > 0 && budHints.length > 0) {
                combinedHint = `[열매] ${fruitHints.join(" ")}\n[겨울눈] ${budHints.join(" ")}`;
            } else if (fruitHints.length > 0) {
                combinedHint = fruitHints.join(" ");
            } else if (budHints.length > 0) {
                combinedHint = `[겨울눈] ${budHints.join(" ")}`;
            }

            console.log(
                `[${tree.name_kr}] Updating ${buds.length} bud instances. New hint: ${combinedHint.replace(/\n/g, " ")}`,
            );

            // Set the new combined hint to all fruit/bud images, and change buds to fruit
            for (const img of images) {
                const updates: any = {};
                if (combinedHint) {
                    updates.hint = combinedHint;
                }
                if (
                    img.image_type === "bud" ||
                    img.image_type === "winter_bud"
                ) {
                    updates.image_type = "fruit";
                }

                if (Object.keys(updates).length > 0) {
                    await supabase
                        .from("tree_images")
                        .update(updates)
                        .eq("id", img.id);
                }
            }
        }
    }
    console.log("Migration complete.");
}
run().catch(console.error);
