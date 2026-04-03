# 기출문제 연동 - 마크다운 제거 및 추출조건 UI 모바일 최적화 (quiz-extraction-markdown-ui-fix)

## 1. 목적 및 범위 (Plan)

- **목적:**
    1. PDF 추출 및 AI 보정 시 생성되는 문제와 정답/해설 내용이 마크다운(`**`, `-`, `#` 등) 형식이 아닌 오직 **순수 일반 텍스트(Plain Text)** 형식으로만 나오도록 AI 시스템 프롬프트를 수정한다.
    2. 모바일 화면에서 추출조건의 콤보박스들(과목명, 년도, 회차, 문제번호)이 강제로 균등배분되어 글자가 잘리거나 Overflow되는 현상을 막기 위해, 컨텐츠 길이에 맞게 자동으로 가로폭이 세팅되고 줄넘김되도록 UI를 조정한다.
- **범위:**
    - `nodejs_admin_api/src/modules/quiz/quiz.service.ts`
    - `flutter_admin_app/lib/features/quiz_management/screens/widgets/quiz_extraction/2_pdf_extraction_module.dart`

## 2. 작업 내용 (Execute)

- **해설/정답 반환 형식 수정 (Node.js API):** `quiz.service.ts` 의 `parseRawSourceToQuizBlocks` 및 `extractQuizFromPdfBuffer` 에 전달되는 Gemini 2.0 프롬프트 내용에 "⚠️ 절대 마크다운(Markdown) 문법(예: ###, \*\*, -, ` 등)을 포함하지 말고, 반드시 순수한 평문(Plain Text) 형식으로만 응답해야 합니다!" 라는 강력한 지시어를 추가.
- **모바일 대응 추출조건 UI 개선 (Flutter App):**
    - 기존의 `Row` 부모 위젯을 화면 너비 초과 시 자연스럽게 다음 줄로 넘어가는 `Wrap` 위젯으로 교체.
    - 컨테이너 폭을 강제로 나누던 `Expanded(flex: N)` 래퍼(Wrapper)들을 모두 제거.
    - `DropdownButton` 의 `isExpanded: true` 속성을 `false` 로 수정하여 각 드롭다운 메뉴 아이템(텍스트 사이즈)에 맞는 최소한의 고유 크기만을 가지도록 변경.

## 3. 사후 점검 (Review)

- **Result (완료된 결과):** 추출된 내용이 더 이상 별 모양(`**`)이나 해시태그(`#`)가 섞이지 않은 평문으로만 나타나며, 브라우저 화면 폭이 좁은 모바일에서도 추출 항목들(과목, 연도 등)이 부드럽게 글씨 길이에 맞게 좁아져 표기되며 필요시 줄넘김 적용 완료.
- **Risk Analysis (향후 문제점 및 리스크 분석):** `Wrap` 레이아웃으로 변경됨에 따라 PC와 같이 아주 넓은 화면에서는 요소들이 좌측에 몰려보일 수 있다. 필요시 Wrap 속성 내 정렬(Alignment) 옵션을 조작할 수 있도록 대응 여지를 두었다. 프롬프트 마크다운 금지 정책에도 불구하고 LLM 특성상 100% 방지가 어려울 수 있으며, 추후 DB 저장 전 정규식(Regex) 단에서 마크다운 특수문자를 한번 더 걸러주는 후처리(Post-processing) 로직이 추가될 필요가 있다.
