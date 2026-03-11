# Task: Quiz Extraction UI Refactoring (Inline Images & Similar Quizzes)

## 1. ANALYSIS (연구 및 분석)

- **문제 내용 입력창**: 현재 `maxLines`가 5로 설정되어 있어 불필요하게 클 수 있음. 3줄 정도로 조정하여 공간 효율성 확보.
- **이미지 보기 방식 변경**: 기존에는 전체화면 뷰어로 새 창(다이얼로그/페이지)을 띄웠으나, 사용자 요청에 따라 '문제지문 아래'에 직접 원본 크기로 노출하도록 변경.
- **유사 기출문제 추천**:
    - **UI**: 현재의 가로형 리스트뷰 대신 사용자 앱(`past_exam_detail_screen.dart`)에 적용된 세로형 카드 리스트 스타일 적용.
    - **로직**: 사용자 앱의 데이터 파싱(블록 필터링, 정렬 등) 로직을 이식하여 일관성 유지.
    - **데이터**: `QuizRepository.recommendRelated`를 활용하여 실제 AI 추천 결과 연동.

## 2. PLANNING (작업 단계별 계획)

### 1단계: 문제/해설 이미지 인라인 표시 구현

- `3_question_explanation_module.dart` 수정:
    - 각 필드(`question`, `explanation`)별로 이미지를 보여줄지 여부를 결정하는 로컬 상태(`_showQuestionImage`, `_showExplanationImage`) 추가.
    - '이미지 보기' 버튼 클릭 시 이 상태를 토글.
    - 상태가 `true`이고 이미지가 존재할 경우, `TextField` 하단에 `Image.network` 배치.
    - `maxLines`를 3(문제) 및 5(해설) 정도로 조정.

### 2단계: 유사 문제 추천 로직 연동

- `QuizExtractionStep2ViewModel` 수정:
    - `recommendSimilarAction` 메서드에서 `_repository.recommendRelated` 호출.
    - 결과 데이터를 `relatedQuizzes` 리스트에 저장.

### 3단계: 유사 문제 UI 이식

- `6_related_question_module.dart` 수정:
    - 사용자 앱의 `_buildRelatedQuizCard` 디자인 코드를 이식.
    - 세로 리스트를 사용하여 추천된 문제들을 나열.
    - 문제 텍스트에서 불필요한 번호 등을 제거하는 정규화 로직 적용.

### 4단계: 검증 및 테스트

- 이미지 인라인 표시 시 레이아웃 깨짐(Overflow) 확인.
- 유사 문제 추천 시 실제 DB 데이터와 연동되는지 확인. (API 응답 구조 검토)

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Inline Display Strategy**: 이미지를 인라인으로 보여줄 때, 원본 크기가 너무 클 경우를 대비해 `BoxFit.contain`과 `constraints`를 적절히 조합하여 유연한 대응.
- **Reusability**: 사용자 앱의 카드 디자인을 거의 그대로 가져오되, 어드민 앱의 다크 모드 테마(primary: #2BEE8C)에 맞게 색상 토큰만 교체.

## 4. IMPLEMENTATION (구현 계획)

- [ ] `QuizExtractionStep2ViewModel.recommendSimilarAction` 구현.
- [ ] `3_question_explanation_module.dart` 인라인 이미지 및 maxLines 수정.
- [ ] `6_related_question_module.dart` UI 전면 개편.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **Layout Overflow**: 인라인으로 이미지를 대량으로 띄울 경우 `SingleChildScrollView` 내부에서 스크롤 부하가 발생할 수 있음.
- **Data Inconsistency**: 추천된 문제의 데이터 구조가 사용자 앱과 상이할 경우 파싱 에러 주의.
