import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(__dirname, "../.env") });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function checkFruitHint() {
    const { data, error } = await supabase
        .from("tree_images")
        .select("hint, is_quiz_enabled")
        .eq("tree_id", 72)
        .eq("image_type", "fruit")
        .single();

    if (error) {
        console.error(error);
        return;
    }

    console.log("--- 아왜나무 열매 힌트 (병합 결과) ---");
    console.log(data.hint);
    console.log(`Quiz Enabled: ${data.is_quiz_enabled}`);

    const { data: budData } = await supabase
        .from("tree_images")
        .select("is_quiz_enabled")
        .eq("tree_id", 72)
        .eq("image_type", "bud")
        .single();

    console.log(`겨울눈 Quiz Enabled: ${budData?.is_quiz_enabled}`);
}

checkFruitHint();
