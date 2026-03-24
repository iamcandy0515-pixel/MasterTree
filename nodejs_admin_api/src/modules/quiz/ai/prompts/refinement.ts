import { CommonRules } from './common';

export const RefinementPrompts = {
    /**
     * Re-generates distractors for a specific question
     */
    GENERATE_DISTRACTOR: (questionText: string, correctOption: string, optionsCount: number) => `
당신은 생물학 및 산림 기출문제 출제 위원입니다. 주어진 문제의 내용과 정답을 바탕으로, 매력적이지만 오답인 보기(Distractors) ${optionsCount}개를 한글로 생성해주세요.
반드시 순수하게 문자열 배열(문자열 목록 JSON) 형식으로만 반환해야 합니다.

Format Requirement:
[ "오답 1", "오답 2", "오답 3" ]

Question: "${questionText}"
Correct Answer: "${correctOption}"
`,

    /**
     * Reviews the alignment between original raw text and the edited quiz content
     */
    REVIEW_ALIGNMENT: (rawText: string, currentQuizBlocksJson: string) => `
당신은 조경, 산림, 식물 분야 기출문제의 품질 보증(QA)을 담당하는 책임 검수자입니다.
아래 제공된 '원본 텍스트(Original Extract)'와 '현재 작성된 문제 데이터(Finalized Quiz)'를 꼼꼼히 비교하여 검수하세요.

**🚨[핵심 검수 및 강제 변환 규칙]🚨**
${CommonRules.EXPLANATION_4_STEPS(false)}

위 4단계 구조에 맞춰 새롭게 교정된 해설을 "suggestedExplanation"에 반환하세요. 
(단, 이미 기존 해설이 완벽하게 위 4단계 구조를 따르고 있고 내용상 오류가 전혀 없다면 "suggestedExplanation"은 null로 반환해도 됩니다.)
${CommonRules.NO_MARKDOWN}

Format Requirement JSON:
{
  "isAligned": true,
  "confidenceScore": 95,
  "reviewComments": ["코멘트 1", "코멘트 2"],
  "suggestedExplanation": "1. 풀이순서: ...\\n2. 공식 및 계산식: ...\\n3. 공식 및 계산식 적용: ...\\n4. 정답: ..."
}

Original Extract (원문):
"""
${rawText}
"""

Finalized Quiz Explanation to check (현재 작성된 해설/데이터):
"""
${currentQuizBlocksJson}
"""
`,

    /**
     * Re-generates hints using AI Assistant
     */
    GENERATE_HINTS: (questionText: string, explanation: string, count: number) => `
당신은 생물학 및 산림 기출문제 출제 위원입니다. 출제된 문제와 해설을 바탕으로 문제를 풀 수 있는 도움이 되는 힌트 ${count}개를 한글로 생성해주세요.
반드시 순수하게 문자열 배열(문자열 목록 JSON) 형식으로만 반환해야 합니다.

Format Requirement:
[ "힌트 1", "힌트 2" ]

Question: "${questionText}"
Explanation: "${explanation}"
`,
};
