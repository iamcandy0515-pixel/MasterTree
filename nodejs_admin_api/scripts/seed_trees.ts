import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

// Load environment variables form .env file in parent directory
dotenv.config({ path: path.resolve(__dirname, "../.env") });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in .env file");
    process.exit(1);
}

// Initialize Supabase client
const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});

const treeNames = [
    "가문비나무",
    "마가목",
    "은행나무",
    "가시나무",
    "매자나무",
    "음나무",
    "가죽나무",
    "물푸레나무",
    "이태리포플러",
    "감나무",
    "박달나무",
    "이팝나무",
    "거제수나무",
    "백합나무",
    "자작나무",
    "고로쇠나무",
    "버즘나무",
    "잣나무",
    "곰솔",
    "버지니아소나무",
    "전나무",
    "구상나무",
    "벚나무",
    "졸참나무",
    "굴참나무",
    "벽오동",
    "주목",
    "까마귀쪽나무",
    "복자기",
    "쪽동백",
    "꽝꽝나무",
    "분비나무",
    "참죽나무",
    "낙엽송",
    "비자나무",
    "채진목",
    "낙우송",
    "사스레피나무",
    "층층나무",
    "노각나무",
    "산딸나무",
    "칠엽수",
    "녹나무",
    "산벚나무",
    "편백",
    "느릅나무",
    "산수유",
    "피나무",
    "느티나무",
    "삼나무",
    "향나무",
    "다릅나무",
    "상수리나무",
    "호두나무",
    "단풍나무",
    "서어나무",
    "화살나무",
    "당단풍나무",
    "소나무",
    "황벽나무",
    "대추나무",
    "쉬나무",
    "황철나무",
    "동백나무",
    "스트로브잣나무",
    "황칠나무",
    "두릅나무",
    "아왜나무",
    "회화나무",
    "들메나무",
    "오동나무",
    "후박나무",
    "때죽나무",
    "오리나무",
    "리기테타소나무",
    "옻나무",
];

async function seedTrees() {
    console.log(`Starting seeding process for ${treeNames.length} trees...`);
    console.log(`Using Supabase URL: ${supabaseUrl}`);

    let addedCount = 0;
    let skippedCount = 0;
    let errorCount = 0;

    for (const name of treeNames) {
        try {
            // Check if tree already exists
            const { data: existing, error: checkError } = await supabase
                .from("trees")
                .select("id")
                .eq("name_kr", name)
                .maybeSingle();

            if (checkError) {
                console.error(`[ERROR] Checking ${name}:`, checkError.message);
                errorCount++;
                continue;
            }

            if (existing) {
                console.log(`[SKIP] ${name} already exists.`);
                skippedCount++;
                continue;
            }

            // Insert new tree
            const { error: insertError } = await supabase.from("trees").insert({
                name_kr: name,
                difficulty: 1, // Default difficulty
                // created_at is automatically handled by Postgres default usually, but explicit is safer if not
            });

            if (insertError) {
                console.error(
                    `[ERROR] Inserting ${name}:`,
                    insertError.message,
                );
                errorCount++;
            } else {
                console.log(`[ADDED] ${name}`);
                addedCount++;
            }
        } catch (e) {
            console.error(`[EXCEPTION] Processing ${name}:`, e);
            errorCount++;
        }
    }

    console.log("\n--------------------------------------------------");
    console.log(`Seeding Completed.`);
    console.log(`Total Inputs: ${treeNames.length}`);
    console.log(`Added: ${addedCount}`);
    console.log(`Skipped: ${skippedCount}`);
    console.log(`Errors: ${errorCount}`);
    console.log("--------------------------------------------------");
}

seedTrees();
