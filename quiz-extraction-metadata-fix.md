# 기출문제 연동 추출조건 UI 복구 및 DB 연동 확인 (quiz-extraction-metadata-fix)

## 1. 목적 및 범위 (Plan)

- **목적:** '기출문제 연동' 화면 내 '추출조건' 하단에 과목, 년도, 회차, 문제번호 선택 UI를 복구하고 올바르게 배치한다. 그리고 해당 추출조건이 '문제 등록' 시 정상적으로 DB 구조에 매핑되어 저장되는지 확인한다.
- **범위:**
    - `2_pdf_extraction_module.dart`: 추출조건 영역 UI 전면 수정
    - `quiz_extraction_step2_viewmodel.dart`: 선택 데이터(과목, 년도, 회차) 보존 로직 수정 및 추가 View 갱신 처리
    - DB 매핑 검증

## 2. 작업 내용 (Execute)

- **UI 복구:** `PdfExtractionModule` 에서 '추출조건' 텍스트 하단에 4개의 Dropdown(`과목`, `년도`, `회차`, `문제번호`)이 가로 스크롤 없이 보기 좋게 배치되도록 Flex 크기를 조정하여 Row 위젯으로 구성하였다.
- **ViewModel 업데이트:** `QuizExtractionStep2ViewModel` 에 `setExtractedSubject`, `setExtractedYear`, `setExtractedRound` 메소드를 추가해 UI 상에서 수동으로 선택한 값이 상태(State)에 반영되도록 하였다.
- **데이터 보존 로직 수정:** PDF 추출(`extractQuiz`) 시 사용자가 이미 설정한 `과목`, `년도`, `회차` 값이 있다면 파일 이름 파싱으로 인해 초기화되거나 덮어써지지 않도록 조건문을 수정하였다 (`if (fileNameText.isNotEmpty && _extractedSubject == null ...)`).
- **매핑 구조 검증:** 프론트엔드의 `saveToDb`를 통해 전달되는 데이터({ 'subject':과목, 'year':년도, 'round':회차, 'question_number':문제번호 })가 Node.js 백엔드의 `quiz.service.ts`의 `upsertQuizQuestion` 메소드에서 아래와 같이 안전하게 DB 테이블과 연계된다는 것을 확인했다.
    - `quiz_categories` 테이블: `subject` (과목 이름) 조회 후 `category_id` 반환 또는 생성
    - `quiz_exams` 테이블: `year` (년도), `round` (회차) 로 조회 후 `exam_id` 반환 또는 생성
    - `quiz_questions` 테이블: 반환받은 `category_id`, `exam_id`와 요청 payload에 담긴 `question_number`(문제번호) 및 해설 콘텐츠를 최종적으로 묶어서 저장

## 3. 사후 점검 (Review)

- **Result (완료된 결과):** 추출조건 항목이 명확하게 4등분 되어 UI에 표기되며, 이를 사용자가 직접 지정하여 '문제 등록' 버튼을 누르면 해당 조건에 맞는 기출문제로 매핑되어 DB에 정상 저장됨.
- **Risk Analysis (향후 문제점 및 리스크 분석):** 년도, 회차, 과목 등의 항목이 스크립트에 고정 배열(`List.generate`)로 할당되어 있다. 추후 새로운 과목이 추가되거나 연도가 지날 경우, 하드코딩된 변수를 서버에서 가져오는 동적(Dynamic) 배열로 변경하는 리팩토링이 필요할 수 있다.
