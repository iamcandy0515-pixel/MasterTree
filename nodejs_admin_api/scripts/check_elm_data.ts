import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(__dirname, "../.env") });

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY!;
const supabase = createClient(supabaseUrl, supabaseKey);

async function checkElm() {
    const { data: tree } = await supabase
        .from("trees")
        .select("id, name_kr")
        .eq("name_kr", "느릅나무")
        .single();

    if (!tree) {
        console.log("Tree not found");
        return;
    }

    const { data: images } = await supabase
        .from("tree_images")
        .select("image_type, hint")
        .eq("tree_id", tree.id);

    console.log(`Tree: ${tree.name_kr} (ID: ${tree.id})`);
    console.log(JSON.stringify(images, null, 2));
}

checkElm();
