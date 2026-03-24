/**
 * Shared Prompt Fragments for Quiz Module
 */

export const CommonRules = {
    // Rule to forbid markdown for mobile display compatibility (Tech Spec 1.4)
    NO_MARKDOWN: `**⚠️ 절대 마크다운(Markdown) 문법(예: ###, **, -, \` 등)을 기입하지 말고, 오직 순수한 평문(Plain Text) 형식으로만 응답해야 합니다!**`,

    // Standard 4-step explanation rule for calculation problems
    EXPLANATION_4_STEPS: (isBatch: boolean = false) => `
계산 및 논리적 풀이가 필요한 경우 반드시 아래 순서와 형식을 지키되, 각 단계 사이는 정확히 줄바꿈 1번만 하세요:
1. **풀이순서**: 접근법 및 핵심 원리 요약
2. **공식 및 계산식**: 활용 공식 (계산이 필요 없는 경우 이 단계는 아예 생략)
3. **공식 및 계산식 적용**: 수치 대입 및 연산 과정. **분자/분모 위치 및 단위 환산**을 완벽하게 검증하세요.
4. **정답**: 최종 도출 결과
${isBatch ? '주의: "해당사항 없음"이나 "필요 없음"과 같은 불필요한 문구는 절대 생성하지 마세요. 내용이 없는 단계는 아예 출력하지 않습니다.' : ''}
    `.trim(),
};
