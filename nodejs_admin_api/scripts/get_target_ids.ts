import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(__dirname, "../.env") });

const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
);

const targetNames = [
    "아왜나무",
    "가문비나무",
    "가시나무",
    "굴참나무",
    "노각나무",
    "녹나무",
    "느티나무",
    "다릅나무",
    "당단풍나무",
    "대추나무",
    "두릅나무",
    "들메나무",
    "버즘나무",
    "비자나무",
    "사스레피나무",
    "산딸나무",
    "산벚나무",
    "산수유",
    "상수리나무",
    "서어나무",
    "소나무",
    "쉬나무",
    "오리나무",
    "옻나무",
    "참죽나무",
    "채진목",
    "층층나무",
    "칠엽수",
    "팽나무",
    "피나무",
    "향나무",
    "호두나무",
    "황철나무",
    "황칠나무",
    "회화나무",
];

async function getTreeIds() {
    const { data, error } = await supabase
        .from("trees")
        .select("id, name_kr")
        .in("name_kr", targetNames);

    if (error) {
        console.error(error);
        return;
    }

    console.log(JSON.stringify(data, null, 2));
}

getTreeIds();
