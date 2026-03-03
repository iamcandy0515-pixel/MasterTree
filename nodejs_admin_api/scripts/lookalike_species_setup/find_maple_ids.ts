import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

async function findMaples() {
    const names = ["단풍나무", "당단풍나무", "고로쇠나무"];
    const { data, error } = await supabase
        .from("trees")
        .select("id, name_kr")
        .in("name_kr", names);

    if (error) console.error(error);
    else console.log(JSON.stringify(data, null, 2));
}
findMaples();
