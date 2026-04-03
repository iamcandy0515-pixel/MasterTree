import fs from "fs";

const trees = [
    { id: 2, name: "가문비나무", current: "침엽수 / 상록수" },
    { id: 8, name: "가시나무", current: "활엽수" },
    { id: 11, name: "가죽나무", current: "활엽수" },
    { id: 14, name: "감나무", current: "활엽수" },
    { id: 17, name: "거제수나무", current: "활엽수" },
    { id: 20, name: "고로쇠나무", current: "활엽수" },
    { id: 23, name: "곰솔", current: "침엽수" },
    { id: 26, name: "구상나무", current: "침엽수" },
    { id: 29, name: "굴참나무", current: "활엽수" },
    { id: 32, name: "까마귀쪽나무", current: "활엽수" },
    { id: 35, name: "꽝꽝나무", current: "활엽수" },
    { id: 38, name: "낙엽송", current: "침엽수" },
    { id: 41, name: "낙우송", current: "침엽수" },
    { id: 44, name: "노각나무", current: "활엽수" },
    { id: 47, name: "녹나무", current: "활엽수" },
    { id: 50, name: "느릅나무", current: "활엽수" },
    { id: 53, name: "느티나무", current: "활엽수" },
    { id: 56, name: "다릅나무", current: "활엽수" },
    { id: 59, name: "단풍나무", current: "활엽수" },
    { id: 62, name: "당단풍나무", current: "활엽수" },
    { id: 65, name: "대추나무", current: "활엽수" },
    { id: 68, name: "동백나무", current: "활엽수" },
    { id: 71, name: "두릅나무", current: "활엽수" },
    { id: 74, name: "들메나무", current: "활엽수" },
    { id: 77, name: "때죽나무", current: "활엽수" },
    { id: 79, name: "리기테타소나무", current: "침엽수" },
    { id: 6, name: "마가목", current: "활엽수" },
    { id: 9, name: "매자나무", current: "활엽수" },
    { id: 12, name: "물푸레나무", current: "활엽수" },
    { id: 15, name: "박달나무", current: "활엽수" },
    { id: 18, name: "백합나무", current: "활엽수" },
    { id: 21, name: "버즘나무", current: "활엽수" },
    { id: 24, name: "버지니아소나무", current: "침엽수" },
    { id: 27, name: "벚나무", current: "활엽수" },
    { id: 30, name: "벽오동", current: "활엽수" },
    { id: 33, name: "복자기", current: "활엽수" },
    { id: 36, name: "분비나무", current: "침엽수" },
    { id: 39, name: "비자나무", current: "침엽수" },
    { id: 42, name: "사스레피나무", current: "활엽수" },
    { id: 45, name: "산딸나무", current: "활엽수" },
    { id: 48, name: "산벚나무", current: "활엽수" },
    { id: 51, name: "산수유", current: "활엽수" },
    { id: 54, name: "삼나무", current: "침엽수" },
    { id: 57, name: "상수리나무", current: "활엽수" },
    { id: 60, name: "서어나무", current: "활엽수" },
    { id: 63, name: "소나무", current: "침엽수" },
    { id: 66, name: "쉬나무", current: "활엽수" },
    { id: 69, name: "스트로브잣나무", current: "침엽수" },
    { id: 81, name: "신갈나무", current: "활엽수" },
    { id: 72, name: "아왜나무", current: "활엽수" },
    { id: 75, name: "오동나무", current: "활엽수" },
    { id: 78, name: "오리나무", current: "활엽수" },
    { id: 80, name: "옻나무", current: "활엽수" },
    { id: 7, name: "은행나무", current: "침엽수" },
    { id: 10, name: "음나무", current: "활엽수" },
    { id: 13, name: "이태리포플러", current: "활엽수" },
    { id: 16, name: "이팝나무", current: "활엽수" },
    { id: 19, name: "자작나무", current: "활엽수" },
    { id: 22, name: "잣나무", current: "침엽수" },
    { id: 25, name: "전나무", current: "침엽수" },
    { id: 28, name: "졸참나무", current: "활엽수" },
    { id: 31, name: "주목", current: "침엽수" },
    { id: 34, name: "쪽동백", current: "활엽수" },
    { id: 37, name: "참죽나무", current: "활엽수" },
    { id: 40, name: "채진목", current: "활엽수" },
    { id: 43, name: "층층나무", current: "활엽수" },
    { id: 46, name: "칠엽수", current: "활엽수" },
    { id: 82, name: "팽나무", current: "활엽수" },
    { id: 49, name: "편백", current: "침엽수" },
    { id: 52, name: "피나무", current: "활엽수" },
    { id: 55, name: "향나무", current: "침엽수" },
    { id: 58, name: "호두나무", current: "활엽수" },
    { id: 61, name: "화살나무", current: "활엽수" },
    { id: 64, name: "황벽나무", current: "활엽수" },
    { id: 67, name: "황철나무", current: "활엽수" },
    { id: 70, name: "황칠나무", current: "활엽수" },
    { id: 73, name: "회화나무", current: "활엽수" },
    { id: 76, name: "후박나무", current: "활엽수" },
];

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
    은행나무: ["침엽수", "낙엽수"], // Botanically Division Ginkgophyta, often grouped here
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
    까마귀쪽나무: ["활엽수", "상록수"], // Litsea japonica, Evergreen

    // Broadleaf Deciduous (활엽수 / 낙엽수) - catch all others
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
    과나무: ["활엽수", "낙엽수"], // Typo in input? Assuming generic
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

let content = "| ID | 수목명 | 기존 Category | 변경 후 Category | 상태 |\n";
content += "|---|---|---|---|---|\n";

trees.forEach((t) => {
    const correction = corrections[t.name];
    let newCategory = t.current;
    let status = "유지";

    if (correction) {
        newCategory = `${correction[0]} / ${correction[1]}`;
        if (t.current !== newCategory) {
            status = "변경 필요";
        }
    } else {
        status = "확인 필요 (DB 미등록)";
    }

    content += `| ${t.id} | ${t.name} | ${t.current} | ${newCategory} | ${status} |\n`;
});

fs.writeFileSync("tree_data_check_list.md", content, "utf8");
console.log("tree_data_check_list.md created.");
