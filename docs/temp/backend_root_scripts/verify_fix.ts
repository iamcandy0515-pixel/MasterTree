import * as dotenv from "dotenv";
import path from "path";
dotenv.config();

import { supabase } from "./src/config/supabaseClient";

async function check() {
    const { data } = await supabase
        .from("trees")
        .select("id, name_kr, tree_images(image_type, thumbnail_url)")
        .in("name_kr", ["소나무", "버지니아소나무"]);

    data?.forEach((t) => {
        console.log(`\nTree: ${t.name_kr} (ID: ${t.id})`);
        t.tree_images.forEach((img: any) => {
            console.log(`  - ${img.image_type}: ${img.thumbnail_url}`);
        });
    });

    process.exit(0);
}

check();
