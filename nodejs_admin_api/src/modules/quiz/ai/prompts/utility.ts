export const UtilityPrompts = {
    /**
     * URL validation against DB subject, year, round from PDF
     */
    VALIDATE_PDF_FILTER: (filterStr: string) => `
당신은 조경, 산림 및 식물 분야의 전문 기출문제 분석가입니다. 제공된 PDF 문서를 읽고 아래 사항을 확인하세요.

**🚨[필터 조건 검증 필수]🚨**
현재 제공된 PDF 문서가 **${filterStr}** 에 해당하는 기출문제인지 확인하세요. 
문서상에서 발견된 실제 과목명, 년도, 회차를 반드시 추출하여 "extracted_subject", "extracted_year", "extracted_round"에 기록하세요. (발견하지 못하면 "알 수 없음" 기입)
그리고 입력된 검색필터와 일치하는지를 "filter_matched" 에 boolean으로 기록하고, 불일치할 경우 "mismatch_reason"에 이유를 적으세요.

반드시 아래 JSON 형식으로만 반환하세요.
{
  "filter_matched": true,
  "mismatch_reason": "",
  "extracted_subject": "예: 산림기사",
  "extracted_year": "예: 2013년",
  "extracted_round": "예: 2회"
}
`,

    /**
     * Recommends related questions from DB using AI & Vector Search
     */
    RECOMMEND_RELATED: (questionText: string, candidates: string, limitCount: number) => `
당신은 조경, 산림 분야 기출문제 마스터입니다.
현재 문제: "${questionText}"

 아래 후보 문제들 리스트에서 현재 문제와 주제, 키워드, 혹은 해결 논리가 유사한 문제를 최대 ${limitCount}개 골라주세요.

**선별 가이드:**
1. 핵심 키워드가 겹치거나 같은 기술 범주(예: 측량, 수목보호 등)에 속하면 추천 대상으로 고려하세요.
2. 현재 문제의 답안을 찾는 데 도움이 될 만한 배경 지식을 담은 문제도 추천 가능합니다.
3. 정말 연관성이 아예 없는 경우에만 빈 배열 []을 반환하세요.

후보 문제들:
${candidates}

반드시 선별된 결과만 아래 JSON 배열 포맷으로 반환해야 합니다. 결과가 없다면 빈 배열 [] 을 반환하세요.
Format Requirement:
[
  {
    "id": 123,
    "year": 2023,
    "round": 1,
    "subject": "산림기사",
    "question_number": 5,
    "question": "문제 텍스트",
    "reason": "추천 사유 (예: 지형 측량의 오차 보정 공식이 동일함)"
  }
]
`,
};
