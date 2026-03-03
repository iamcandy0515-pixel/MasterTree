import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function checkCount() {
    const { count, error } = await supabase
        .from("tree_groups")
        .select("*", { count: "exact", head: true });
    if (error) console.error(error);
    else console.log("Tree Groups Count:", count);
}
checkCount();
