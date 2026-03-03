import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import path from "path";

// Specify the path to .env file relative to current execution context
dotenv.config({ path: path.resolve(__dirname, "../../.env") });

if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_KEY) {
    console.error(
        "Environment variables SUPABASE_URL or SUPABASE_SERVICE_KEY are missing.",
    );
    process.exit(1);
}

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
);

(async () => {
    try {
        const { data: tree } = await supabase
            .from("trees")
            .select("id, name_kr")
            .eq("name_kr", "다릅나무")
            .single();

        if (!tree) {
            console.log("다릅나무를 찾을 수 없습니다.");
            return;
        }

        console.log(
            `Checking images for Tree: ${tree.name_kr} (ID: ${tree.id})`,
        );

        const { data: images, error } = await supabase
            .from("tree_images")
            .select("*")
            .eq("tree_id", tree.id);

        if (error) {
            console.error("Error fetching images:", error);
            return;
        }

        if (!images || images.length === 0) {
            console.log("No images found in database.");
        } else {
            console.log(`Found ${images.length} images in DB.`);
            for (const img of images) {
                console.log(`- Type: ${img.image_type}, URL: ${img.image_url}`);
                try {
                    const res = await fetch(img.image_url, { method: "HEAD" });
                    console.log(
                        `  > Network Check: ${res.status} ${res.statusText}`,
                    );
                } catch (e: any) {
                    console.log(`  > Network Check Failed: ${e.message}`);
                }
            }
        }
    } catch (e) {
        console.error("Unexpected error:", e);
    }
})();
