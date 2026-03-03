# 기출문제 일람 UI 및 네비게이션 개선 사항 핫픽스

## 1. 목적 및 범위 (Plan)

- **신규등록 라우팅 수정:** '기출문제 일람(QuizManagementScreen)'에서 '신규등록' 버튼 클릭 시 `QuizExtractionScreen` (1단계)로 가던 구성을 사용자 요청에 따라 `QuizExtractionStep2Screen` (2단계 - 구글연동 2단계 상세 화면)으로 직행하도록 변경.
- **카드 리스트 스타일 변경:** 기출문제 목록에 표시되는 카드 형태 요소들에 대해 배경색과 테두리(Border)를 걷어내고, 단순한 Text Box(텍스트 박스) 형태로 렌더링되도록 디자인을 평탄화(Flat).
- **문제번호 표시 수정:** 카드 리스트 클릭을 통해 진입하는 상세 조회 화면(`QuizReviewDetailScreen`)에서 UUID가 아닌, DB에 기록된 실제 '문제 번호(`question_number`)'를 로드하여 표시하도록 연동 로직 정상화.

## 2. 작업 내용 (Execute)

- `quiz_management_screen.dart`:
    - `Navigator.push` 호출부에서 목적지를 `QuizExtractionStep2Screen(selectedFiles: [])`으로 변경하여 바로 2단계 워크플로우를 진입할 수 있도록 조치.
    - 리스트 아이템을 렌더링하는 `_buildQuizTextCard`에서 `Card` 위젯(배경색 surfaceDark, 테두리 white10)을 지우고, 대신 `Container` 내부에 `Material(color: Colors.transparent)`를 둘러 텍스트 중심으로 아주 깔끔하고 투명하게 보이도록 스타일 개편.
    - 불필요해진 `QuizExtractionScreen` 임포트 제거.
- `quiz_review_detail_screen.dart`:
    - `_fetchQuizData` 내부에서 `_questionNo` 변수에 데이터를 바인딩할 때 기존 `response['id']`를 그대로 사용하던 코드를 `response['question_number']` 우선 파싱 구조로 변경하고, 없을 경우에만 폴백으로 id를 쓰도록 보강.

## 3. 사후 점검 (Review)

- **Result:**
    - 사용자는 '신규등록'을 누르자마자 중간 검색 화면을 생략하고 곧바로 문제 추출 2단계 입력 인터페이스로 진입할 수 있습니다.
    - 기출문제 일람 목록은 투박한 카드 박스를 벗어나 투명한 텍스트 뷰 형태가 되어 가독성이 올라갔습니다.
    - 특정 문제를 누르면 우측 상단이나 필드에 표기되는 '문제번호'가 `quiz_questions.question_number` 컬럼의 실 데이터를 정확히 반영하게 됩니다.
- **Risk Analysis:**
    - 2단계로 바로 넘어갈 시 `selectedFiles`가 빈 상태(`[]`)가 되는데, 2단계 뷰모델 내부에서 파일 없이도 정상 구동 가능한지 사전에 검토 완료하였으나, 만약 사용자가 직접 PDF를 Google Drive에서 선택하려 할 때는 2단계 모듈 내장 구글 검색 컴포넌트를 호출해야 하므로 UX 상 어떤 흐름인지를 지속 모니터링할 필요가 있습니다.
    - 카드 배경과 테두리를 삭제해 리스트간의 구분선이 약화될 수 있습니다. 필요 시 하단 `Divider`를 추가해야 할 수도 있습니다.
