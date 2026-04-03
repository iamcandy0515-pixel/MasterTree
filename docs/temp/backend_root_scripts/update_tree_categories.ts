import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

// Define corrections: Name -> [Conifer/Broadleaf, Evergreen/Deciduous]
const corrections: Record<string, [string, string]> = {
    // Conifers (침엽수)
    가문비나무: ["침엽수", "상록수"],
    곰솔: ["침엽수", "상록수"],
    구상나무: ["침엽수", "상록수"],
    낙엽송: ["침엽수", "낙엽수"],
    낙우송: ["침엽수", "낙엽수"],
    리기테타소나무: ["침엽수", "상록수"],
    버지니아소나무: ["침엽수", "상록수"],
    분비나무: ["침엽수", "상록수"],
    비자나무: ["침엽수", "상록수"],
    삼나무: ["침엽수", "상록수"],
    소나무: ["침엽수", "상록수"],
    스트로브잣나무: ["침엽수", "상록수"],
    은행나무: ["침엽수", "낙엽수"],
    잣나무: ["침엽수", "상록수"],
    전나무: ["침엽수", "상록수"],
    주목: ["침엽수", "상록수"],
    편백: ["침엽수", "상록수"],
    향나무: ["침엽수", "상록수"],

    // Broadleaf Evergreens (활엽수 / 상록수)
    가시나무: ["활엽수", "상록수"],
    녹나무: ["활엽수", "상록수"],
    동백나무: ["활엽수", "상록수"],
    아왜나무: ["활엽수", "상록수"],
    후박나무: ["활엽수", "상록수"],
    황칠나무: ["활엽수", "상록수"],
    사스레피나무: ["활엽수", "상록수"],
    꽝꽝나무: ["활엽수", "상록수"],
    까마귀쪽나무: ["활엽수", "상록수"],

    // Broadleaf Deciduous (활엽수 / 낙엽수)
    가죽나무: ["활엽수", "낙엽수"],
    감나무: ["활엽수", "낙엽수"],
    거제수나무: ["활엽수", "낙엽수"],
    고로쇠나무: ["활엽수", "낙엽수"],
    굴참나무: ["활엽수", "낙엽수"],
    노각나무: ["활엽수", "낙엽수"],
    느릅나무: ["활엽수", "낙엽수"],
    느티나무: ["활엽수", "낙엽수"],
    다릅나무: ["활엽수", "낙엽수"],
    단풍나무: ["활엽수", "낙엽수"],
    당단풍나무: ["활엽수", "낙엽수"],
    대추나무: ["활엽수", "낙엽수"],
    두릅나무: ["활엽수", "낙엽수"],
    과나무: ["활엽수", "낙엽수"],
    들메나무: ["활엽수", "낙엽수"],
    때죽나무: ["활엽수", "낙엽수"],
    마가목: ["활엽수", "낙엽수"],
    매자나무: ["활엽수", "낙엽수"],
    물푸레나무: ["활엽수", "낙엽수"],
    박달나무: ["활엽수", "낙엽수"],
    백합나무: ["활엽수", "낙엽수"],
    버즘나무: ["활엽수", "낙엽수"],
    벚나무: ["활엽수", "낙엽수"],
    벽오동: ["활엽수", "낙엽수"],
    복자기: ["활엽수", "낙엽수"],
    산딸나무: ["활엽수", "낙엽수"],
    산벚나무: ["활엽수", "낙엽수"],
    산수유: ["활엽수", "낙엽수"],
    상수리나무: ["활엽수", "낙엽수"],
    서어나무: ["활엽수", "낙엽수"],
    쉬나무: ["활엽수", "낙엽수"],
    신갈나무: ["활엽수", "낙엽수"],
    오동나무: ["활엽수", "낙엽수"],
    오리나무: ["활엽수", "낙엽수"],
    옻나무: ["활엽수", "낙엽수"],
    음나무: ["활엽수", "낙엽수"],
    이태리포플러: ["활엽수", "낙엽수"],
    이팝나무: ["활엽수", "낙엽수"],
    자작나무: ["활엽수", "낙엽수"],
    졸참나무: ["활엽수", "낙엽수"],
    쪽동백: ["활엽수", "낙엽수"],
    참죽나무: ["활엽수", "낙엽수"],
    채진목: ["활엽수", "낙엽수"],
    층층나무: ["활엽수", "낙엽수"],
    칠엽수: ["활엽수", "낙엽수"],
    팽나무: ["활엽수", "낙엽수"],
    피나무: ["활엽수", "낙엽수"],
    호두나무: ["활엽수", "낙엽수"],
    화살나무: ["활엽수", "낙엽수"],
    황벽나무: ["활엽수", "낙엽수"],
    황철나무: ["활엽수", "낙엽수"],
    회화나무: ["활엽수", "낙엽수"],
};

async function updateCategories() {
    console.log("Starting category updates...");
    let successCount = 0;
    let failCount = 0;
    let skipCount = 0;

    for (const [name, [type1, type2]] of Object.entries(corrections)) {
        const newCategory = `${type1} / ${type2}`;

        // Check if update is needed (optional, but good for logging)
        const { data: trees } = await supabase
            .from("trees")
            .select("id, category")
            .eq("name_kr", name);

        if (!trees || trees.length === 0) {
            console.log(`Skipping ${name} (Not found in DB)`);
            continue;
        }

        const tree = trees[0];
        if (tree.category === newCategory) {
            skipCount++;
            continue;
        }

        const { error } = await supabase
            .from("trees")
            .update({ category: newCategory })
            .eq("id", tree.id);

        if (error) {
            console.error(`Failed to update ${name}:`, error.message);
            failCount++;
        } else {
            console.log(`Updated ${name}: ${tree.category} -> ${newCategory}`);
            successCount++;
        }
    }

    console.log("--------------------------------------------------");
    console.log(`Update Complete.`);
    console.log(`Updated: ${successCount}`);
    console.log(`Skipped (Already correct): ${skipCount}`);
    console.log(`Failed: ${failCount}`);
}

updateCategories();
