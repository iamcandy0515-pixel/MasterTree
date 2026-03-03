import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function testQuery() {
    console.log("Testing Service Query...");
    const { data, error } = await supabase
        .from("tree_groups")
        .select(
            `
            id,
            group_name,
            description,
            created_at,
            tree_group_members (
                id,
                sort_order,
                trees (
                    id,
                    name_kr,
                    tree_images (
                        image_url,
                        image_type
                    )
                )
            )
        `,
        )
        .range(0, 9);

    if (error) {
        console.error("❌ Query Failed:", error);
    } else {
        console.log(`✅ Success! Got ${data.length} rows.`);
        if (data.length > 0) console.log(JSON.stringify(data[0], null, 2));
    }
}
testQuery();
