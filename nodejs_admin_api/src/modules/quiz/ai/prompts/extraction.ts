import { CommonRules } from './common';

export const ExtractionPrompts = {
    /**
     * Parses raw PDF text into structured quiz questions
     */
    PARSE_RAW_SOURCE: (rawText: string) => `
You are an expert botany and forestry exam parser. Convert the following raw exam text into a structured JSON array of quiz questions.
If a question is a subjective or short-answer type, automatically generate 1 plausible distractor (incorrect option) to make it a multiple choice question.
${CommonRules.NO_MARKDOWN}

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
${CommonRules.EXPLANATION_4_STEPS(false)}

**🚨[수식 작성 규칙]🚨**: 계산 문제의 '정답 및 해설'(explanation_blocks) 작성 시, 수식(LaTeX 문법 등)을 절대 사용하지 말고, 기호나 특수문자 표현을 일반 한글/영문 텍스트로 풀어 쓰거나 가장 기본적인 텍스트 기호(+, -, *, / 등)만 사용하여 작성하세요. Markdown 문법도 모두 제외한 순수 평문(Plain Text) 형식으로만 작성해 주세요.

"hint_blocks"에는 문제를 푸는 데 도움이 되는 매력적인 힌트 ${optionsCount}개를 배열 형식으로 넣으세요.
"options"에는 정답 1개와 매력적인 오답(Distractors) 3개를 섞어 총 4개의 보기가 되도록 구성하세요. "correct_option_index"에 해당 옵션 중 정답의 인덱스(0, 1, 2, 3 중 하나)를 기입하세요.

**🚨[가장 중요한 규칙 - 환각(Hallucination) 방지 및 번호 고정]🚨**
제공된 PDF 텍스트 내에 정확히 **"${questionNumberStr}"**, **"${questionNumberPadded}"**, **"Q${questionNumberStr}"**, **"문 ${questionNumberStr}"** 등으로 명시된 해당 번호의 문제가 없다면 절대 다른 번호를 가져오지 마세요.
반드시 당신이 추출한 문제가 요청한 번호가 맞는지 스스로 두 번 이상 크로스체크 한 뒤 최종 반환하세요.
만약 해당 번호의 문제를 명확히 찾을 수 없다면, 파싱을 중단하고 "data" 필드를 **빈 배열 []** 로 반환해야 합니다.
${CommonRules.NO_MARKDOWN}

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
     * Generates a specialized prompt for batch quiz extraction
     */
    BATCH_EXTRACT: (start: number, end: number) => `
당신은 조경, 산림 및 식물 분야의 전문 기출문제 분석가입니다. 제공된 PDF 문서를 읽고 아래 범주의 문제들을 추출하세요.

**🚨[추출 범위: ${start}번 ~ ${end}번]🚨**
- 반드시 위 범위에 해당하는 문제만 추출해야 합니다. 
- 만약 특정 번호의 문제가 문서 내에 없다면, 억지로 다른 문제를 가져오지 말고 해당 번호는 결과 배열에서 제외(Skip)하세요.

**🚨[카테고리별 추출 및 가공 규칙]🚨**
1. **문제 (Content)**:
   - "문제번호 + 본문" 형식으로 추출
   - 문항 번호 앞의 불필요한 섹션 번호나 페이지 번호는 반드시 제외하세요.
2. **정답과 해설 (Explanation)**:
${CommonRules.EXPLANATION_4_STEPS(true)}
    - **정답 및 해설 추출 규칙**: 원문 텍스트 내에 **'→'** 기호가 있다면, 해당 기호 뒤에 나오는 모든 내용(정답 포함)을 분석하여 위 4단계 해설 구조에 맞게 가공하여 추출하세요.
    - **🚨[그림/이미지 해석 규칙]🚨**: 그림 안의 모든 수치, 명칭, 범례를 정밀하게 읽어내어 사용자가 그림을 보지 않고도 이해할 수 있도록 위 4단계 구조에 녹여내야 합니다.
3. **힌트 (Hints)**: 문항당 가장 도움이 되는 핵심 힌트 **2가지**를 배열로 생성하세요.
4. **옵션 (Options)**: **정답 1개와 매력적인 오답 1개**를 포함하여 총 2개의 보기를 구성하세요.

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
${CommonRules.NO_MARKDOWN}
`,
};
