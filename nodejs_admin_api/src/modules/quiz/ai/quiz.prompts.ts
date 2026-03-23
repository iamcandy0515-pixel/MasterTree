/**
 * Quiz AI Prompts Registry
 * Centralized location for all Gemini prompts used in Quiz module.
 * Following Rule 1-1 of DEVELOPMENT_RULES.md for source splitting.
 */

export const QuizPrompts = {
    /**
     * Parses raw PDF text into structured quiz questions
     */
    PARSE_RAW_SOURCE: (rawText: string) => `
You are an expert botany and forestry exam parser. Convert the following raw exam text into a structured JSON array of quiz questions.
If a question is a subjective or short-answer type, automatically generate 1 plausible distractor (incorrect option) to make it a multiple choice question.
**⚠️ 절대 마크다운(Markdown) 문법(예: ###, **, -, \` 등)을 기입하지 말고, 오직 순수한 평문(Plain Text) 형식으로만 응답해야 합니다!**

Format Requirement:
[
  {
    "raw_source_text": "Original text of the question",
    "content_blocks": [ { "type": "text", "content": "Question text here" } ],
    "hint_blocks": [ { "type": "text", "content": "Hint here if any, else empty string" } ],
    "options": [ { "type": "text", "content": "Option 1" }, { "type": "text", "content": "Option 2" } ],
    "correct_option_index": 0,
    "explanation_blocks": [ { "type": "text", "content": "Explanation here" } ],
    "difficulty": 1
  }
]

Raw Text:
"""
${rawText}
"""
`,

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
기존 해설이나 정답에 수식, 계산, 또는 논리적 풀이가 포함되어 있을 경우, AI는 '문제' 텍스트를 제외하고 오로지 **'정답 및 해설(Explanation)'** 부분을 분석하여 핵심 내용을 요약한 뒤, **반드시 다음 4가지 순서로 명확하게 재해석하고 변환하여 출력**해야 합니다.
(단순 암기 문제의 경우에도 핵심 내용을 요약하여 최대한 논리적으로 구조화하여 작성할 것)

1. 풀이순서
2. 공식 및 계산식
3. 공식 및 계산식 적용
4. 정답

**🚨[주의사항]🚨**: 
- 분자/분모의 자리가 뒤바뀌지 않았는지, 계산 과정이 수학적으로 완벽한지 스스로 철저히 검증하세요.
- 마크다운 문법(예: ###, **, -, \` 등)이나 LaTeX 식을 절대 사용하지 말고, 누구나 모바일 화면에서 쉽게 읽을 수 있는 평문(Plain Text) 형태로만 작성해야 합니다.

위 4단계 구조에 맞춰 새롭게 교정된 해설을 "suggestedExplanation"에 반환하세요. 
(단, 이미 기존 해설이 완벽하게 위 4단계 구조를 따르고 있고 내용상 오류가 전혀 없다면 "suggestedExplanation"은 null로 반환해도 됩니다.)

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
     * Extracts structured quiz blocks from a PDF buffer focusing on a specific item number
     */
    EXTRACT_SINGLE_QUIZ: (questionNumber: number, questionNumberStr: string, questionNumberPadded: string, optionsCount: number) => `
당신은 조경, 산림 및 식물 분야의 전문 기출문제 분석가입니다. 제공된 PDF 문서를 읽고 아래 1가지 기능을 반드시 수행하세요.

**🚨[1단계: 일치하는 문제 추출 기능 - 매우 엄격한 규칙]🚨**
제공된 PDF 문서 내용 중에서 오직 **문제 번호가 ${questionNumber}번(또는 ${questionNumberStr}, ${questionNumberPadded}, Q${questionNumberStr})인 문제 단 하나만** 찾아 추출해야 합니다. 
만약 해당 번호가 아닌 다른 번호의 문제를 추출할 경우 즉각적인 시스템 치명적 오류로 간주됩니다!
절대로 요청한 번호가 아닌 다른 문제(예: 1번 문제)를 임의로 대신 추출하지 마세요. 
만약 문서 내에 해당 번호의 문제가 없다면 반드시 "data" 필드를 **빈 배열 []** 로 반환해야 합니다. 다른 번호로 대체하지 마세요.

추출한 내용을 바탕으로 아래의 **JSON Object** 형식으로 정확히 반환해주세요. 출력의 모든 텍스트는 **반드시 한글(Korean)**로 작성되어야 합니다.
수식이나 계산식이 포함된 경우라도, **LaTeX(라텍스) 등 어떠한 변환 처리도 하지 말고 이미지에 보이는 텍스트 그대로(Raw Text)** 추출해야 합니다. 
        
"content_blocks"에는 반드시 해당 번호 문제의 질문 텍스트 원본을 훼손 없이 있는 그대로 기입하세요.
"explanation_blocks"에는 정답과 문제에 대한 해설을 작성합니다.
**[중요: 계산 문제인 경우 필수 준수 사항]**
계산 문제일 경우에는 '문제' 텍스트를 제외하고 오로지 '정답 및 해설' 부분을 분석하여 핵심 내용을 요약한 뒤, 반드시 아래 4단계 순서대로 해설을 작성하세요:
1. **풀이순서:** (문제를 풀기 위한 접근 방법 및 핵심 내용 요약)
2. **공식 및 계산식:** (사용할 수학/물리 공식 및 기본 식)
3. **공식 및 계산식 적용:** (수치 대입 과정. 🚨주의: 계산 전 분자와 분모의 자리가 뒤바뀌진 않았는지, 단위 변환이 올바른지 자체적으로 완벽하게 검증하고 정확하게 대입할 것!)
4. **정답:** (최종 계산 결과)
(단, 단순 암기 문제라면 원본 해설을 최대한 유지하여 평문으로 입력하세요.)
**🚨[수식 작성 규칙]🚨**: 계산 문제의 '정답 및 해설'(explanation_blocks) 작성 시, 수식(LaTeX 문법 등)을 절대 사용하지 말고, 기호나 특수문자 표현을 일반 한글/영문 텍스트로 풀어 쓰거나 가장 기본적인 텍스트 기호(+, -, *, / 등)만 사용하여 작성하세요. Markdown 문법도 모두 제외한 순수 평문(Plain Text) 형식으로만 작성해 주세요.

"hint_blocks"에는 문제를 푸는 데 도움이 되는 매력적인 힌트 ${optionsCount}개를 배열 형식으로 넣으세요.
"options"에는 정답 1개와 매력적인 오답(Distractors) 3개를 섞어 총 4개의 보기가 되도록 구성하세요. "correct_option_index"에 해당 옵션 중 정답의 인덱스(0, 1, 2, 3 중 하나)를 기입하세요.

**🚨[가장 중요한 규칙 - 환각(Hallucination) 방지 및 번호 고정]🚨**
제공된 PDF 텍스트 내에 정확히 **"${questionNumberStr}"**, **"${questionNumberPadded}"**, **"Q${questionNumberStr}"**, **"문 ${questionNumberStr}"** 등으로 명시된 해당 번호의 문제가 없다면 절대 다른 번호를 가져오지 마세요.
반드시 당신이 추출한 문제가 요청한 번호가 맞는지 스스로 두 번 이상 크로스체크 한 뒤 최종 반환하세요.
만약 해당 번호의 문제를 명확히 찾을 수 없다면, 파싱을 중단하고 "data" 필드를 **빈 배열 []** 로 반환해야 합니다.
**⚠️ 내용 작성 시 절대 마크다운(Markdown) 문법(예: ###, **, -, \` 등)을 포함하지 말고, 반드시 순수한 평문(Plain Text) 형식으로만 응답해야 합니다!**

Format Requirement:
{
  "data": [
    {
      "extracted_question_number": "${questionNumberStr}",
      "raw_source_text": "원문 텍스트 전체",
      "content_blocks": [ { "type": "text", "content": "문제 텍스트" } ],
      "hint_blocks": [ { "type": "text", "content": "힌트 1" }, { "type": "text", "content": "힌트 2" } ],
      "options": [ { "type": "text", "content": "보기 1" }, { "type": "text", "content": "보기 2" }, { "type": "text", "content": "보기 3" }, { "type": "text", "content": "보기 4" } ],
      "correct_option_index": 0,
      "explanation_blocks": [ { "type": "text", "content": "상세한 해설 및 정답 텍스트" } ],
      "difficulty": 1
    }
  ],
  "error": "원하는 번호가 없을 경우 등 에러 메시지가 있다면 기입"
}
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

    /**
     * Generates a specialized prompt for batch quiz extraction
     */
    BATCH_EXTRACT: (start: number, end: number) => `
당신은 조경, 산림 및 식물 분야의 전문 기출문제 분석가입니다. 제공된 PDF 문서를 읽고 아래 범주의 문제들을 추출하세요.

**🚨[추출 범위: ${start}번 ~ ${end}번]🚨**
- 반드시 위 범위에 해당하는 문제만 추출해야 합니다. 
- **[경고]**: 요청하지 않은 번호(예: 범위 밖의 번호)를 임의로 추출하는 것은 시스템 장애를 유발하는 치명적인 행위입니다.
- 만약 특정 번호의 문제가 문서 내에 없다면, 억지로 다른 문제를 가져오지 말고 해당 번호는 결과 배열에서 제외(Skip)하세요.

**🚨[카테고리별 추출 및 가공 규칙]🚨**

1. **문제 (Content)**:
   - "문제번호 + 본문" 형식으로 추출 (예: "${start}. 다음 중 ...")
   - 문항 번호 앞의 불필요한 섹션 번호나 페이지 번호(2자리 숫자 등)는 반드시 제외하세요.
   - **표(Table) 처리**: 표가 있을 경우 기계적 구조 유지보다 **내용의 의미 해석**에 집중하세요. 원문의 수치와 논리 관계가 어긋나지 않도록 스스로 **철저히 교차 검증**한 뒤 텍스트로 변환하세요.

2. **정답과 해설 (Explanation - 엄격한 4단계 평문)**:
   - 계산 및 논리적 풀이가 필요한 경우 반드시 아래 순서와 형식을 지키되, 각 단계 사이는 **정확히 줄바꿈 1번**만 하세요:
     1. **풀이순서**: 접근법 및 핵심 원리 요약
     2. **공식 및 계산식**: 활용 공식 (계산이 필요 없는 경우 이 단계는 아예 생략)
     3. **공식 및 계산식 적용**: 수치 대입 및 연산 과정. **분자/분모 위치 및 단위 환산**을 완벽하게 검증하세요. (계산이 필요 없는 경우 이 단계는 아예 생략)
     4. **정답**: 최종 도출 결과
    - **정답 및 해설 추출 규칙**: 원문 텍스트 내에 **'→'** 기호가 있다면, 해당 기호 뒤에 나오는 모든 내용(정답 포함)을 분석하여 위 4단계 해설 구조에 맞게 가공하여 추출하세요.
    - **🚨[그림/이미지 해석 규칙]🚨**: 만약 해설 부분이 텍스트가 아닌 그림(도표, 그래프, 다이어그램, 수식 이미지 등)이라면, 다음을 반드시 수행하세요:
      1. **시각적 텍스트 검색(Visual OCR)**: 그림 안의 모든 수치, 명칭, 범례를 정밀하게 읽어내세요.
      2. **핵심 요약**: 읽어낸 정보 중 문제 풀이에 필수적인 '핵심 데이터'만 선별하여 요약하세요.
      3. **설명 및 해석**: 요약된 정보와 그림의 시각적 형태(추세, 관계)를 결합하여 논리적으로 설명하세요. '그림 참고'라고만 적는 것은 절대 금지하며, 사용자가 그림을 보지 않고도 이해할 수 있도록 위 4단계 구조에 녹여내야 합니다.
    - **주의**: "해당사항 없음"이나 "필요 없음"과 같은 불필요한 문구는 절대 생성하지 마세요. 내용이 없는 단계는 아예 출력하지 않습니다.
    - **평문 전용**: LaTeX, Markdown(###, **, \` 등) 절대 사용 금지. 기호는 (+, -, *, /) 등 기본 텍스트만 사용하세요.
    - 단순 암기 문제도 위 단계를 논리적으로 구조화하여 작성하되, 공식/적용 단계가 없으면 1번과 4번만 출력하세요.

3. **힌트 (Hints)**: 문항당 가장 도움이 되는 핵심 힌트 **2가지**를 배열로 생성하세요.
4. **옵션 (Options)**: **정답 1개와 매력적인 오답 1개**를 포함하여 총 2개의 보기를 구성하세요. (2지 선다형)

**🚨[반환 형식: JSON Object]🚨**
{
  "data": [
    {
      "question_number": 1,
      "content_blocks": "문제 본문",
      "explanation_blocks": "4단계 해설 (줄바꿈 적용)",
      "hint_blocks": ["힌트1", "힌트2"],
      "options": ["정답/오답1", "정답/오답2"],
      "correct_option_index": 0
    }
  ]
}

**⚠️ 모든 응답은 반드시 순수한 평문(Plain Text) 형식으로 작성되어야 하며, 데이터의 정확성을 최우선으로 합니다!**
`,
};
