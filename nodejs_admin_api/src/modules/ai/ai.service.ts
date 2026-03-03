import { geminiPredict, geminiGenerateText } from "../../config/geminiClient";

export class AiService {
    static async predict(imageUrl: string) {
        return await geminiPredict(imageUrl);
    }

    static async getComparisonHint(tree1: string, tree2: string, tag: string) {
        const prompt = `주제: 수목 비교 가이드
비교 대상: ${tree1} vs ${tree2}
집중 부위: ${tag} (예: 잎, 수피)

위 두 수종을 ${tag} 부위에서 어떻게 쉽게 구분할 수 있는지 한국어로 간략하고 명확하게 설명해주세요. 
답변은 반드시 아래 JSON 형식을 지켜주세요:
{
  "hint": "구분법 설명..."
}`;
        return await geminiGenerateText(prompt);
    }
}
