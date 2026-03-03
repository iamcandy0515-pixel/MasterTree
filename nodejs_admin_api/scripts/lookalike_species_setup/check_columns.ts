import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function checkColumns() {
    const { data, error } = await supabase
        .from("tree_group_members")
        .select("*")
        .limit(1);

    if (error) {
        console.error("Query Error:", error);
    } else if (data && data.length > 0) {
        console.log("Columns:", Object.keys(data[0]));
    } else {
        console.log("No data found to deduce columns.");
    }
}
checkColumns();
