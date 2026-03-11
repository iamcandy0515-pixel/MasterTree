# Task: Quiz Extraction - Similar Question Logic Refactoring (Modal Management)

## 1. ANALYSIS (연구 및 분석)

### 1-1. 현재 방식 (AS-IS)

- `6_related_question_module.dart`에서 'AI 유사 기출문제 분석' 버튼 클릭 시 즉시 리스트가 화면 하단에 펼쳐짐.
- 리스트의 각 카드에 'X' 버튼이 있어 즉시 삭제는 가능하지만, 화면이 길어지는 단점이 있음.

### 1-2. 개선 방식 (TO-BE)

- **라벨 변경**: 'AI 유사 기출문제 분석' -> **'유사문제 추출'**.
- **UI 흐름 변경**:
    1. '유사문제 추출' 클릭 시 AI 분석 수행.
    2. 분석 완료 후 **'추출된 유사 문제: N개'** 메시지와 함께 **[보기]** 버튼 노출.
    3. **[보기]** 클릭 시 모달(Dialog) 창을 띄움.
    4. 모달 창 내에서 유사 문제 리스트를 확인하고 삭제('X') 관리.
    5. '닫기' 클릭 시 수정된 상태 반영 및 최종 'DB 저장' 시 확정.
- **참조 모델**: `bulk_similar_management_screen.dart`의 `_showReviewDialog` 로직 및 카드 디자인 스타일 이식.

## 2. PLANNING (작업 단계별 계획)

### 1단계: ViewModel 공유 로직 점검

- `QuizExtractionStep2ViewModel`에서 유사 문제 목록(`relatedQuizzes`) 관리 로직 확인.
- 이미 `removeRelatedQuiz` 메서드가 존재하므로 모달 내에서 호출 가능하게 연동.

### 2단계: UI 모듈 (`6_related_question_module.dart`) 개편

- 버튼 라벨 명칭 변경.
- 분석 완료 후 상태(Count + 보기 버튼) 표현 UI 추가.
- 하단의 `ExpansionTile` 또는 리스트 카드를 제거하고 모달 호출 로직으로 대체.

### 3단계: 유사 문제 관리 모달(Dialog) 구현

- `BulkSimilarManagementScreen`의 다이얼로그 디자인을 이식하여 `6_related_question_module.dart` 내부에 `_showSimilarQuizzesModal` 구현.
- 리스트 카드 내 삭제 아이콘 배치 및 동기화.

### 4단계: 통합 테스트 및 검증

- 유사 문제 추출 -> 모달 열기 -> 일부 삭제 -> 모달 닫기 -> 최종 DB 저장 시 삭제된 결과가 반영되는지 테스트.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **UX Improvement**: 추출 결과가 화면을 많이 차지하지 않게 하여 메인 퀴즈 편집 시 가독성 확보.
- **Logic Reusability**: '기출유사문제추출(일괄)' 화면과 동일한 사용 환경을 제공하여 운영자 혼선 방지.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `6_related_question_module.dart` 버튼 및 메시지 영역 수정.
- [ ] `_showSimilarQuizzesModal` (AlertDialog 기반) 추가.
- [ ] 모달 내 리스트 렌더링 및 삭제 액션 연결.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **상태 동기화**: 모달에서 삭제한 내용이 ViewModel에 즉시 반영되는지 확인(Provider 사용 시 자동 반영 예정).
- **UI 일관성**: 모달 내의 카드 스타일이 Admin 앱의 전체적인 Dark 테마(surfaceDark)와 일치하도록 조정.
