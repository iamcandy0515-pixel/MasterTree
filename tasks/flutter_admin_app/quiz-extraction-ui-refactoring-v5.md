# Task: Quiz Extraction UI Refactoring (Related Quiz Management & Final Polish)

## 1. ANALYSIS (연구 및 분석)

- **유사 기출문제 관리 기능 추가**: AI가 추천한 유사 문제 목록 중 부적절한 문제를 관리자가 직접 제거할 수 있어야 함.
- **UI 요구사항**: 각 유사 문제 리스트 카드 우측에 삭제 아이콘('X')을 배치하여 직관적인 조정을 지원.
- **동작**: 삭제 아이콘 클릭 시 해당 카드가 목록에서 즉시 제거되어 최종 저장 전 관리자가 내용을 필터링할 수 있도록 함.

## 2. PLANNING (작업 단계별 계획)

### 1단계: ViewModel 관리 기능 확장

- `QuizExtractionStep2ViewModel` 수정:
    - `removeRelatedQuiz(int index)` 메서드 추가: 추천된 유사 문제 목록에서 특정 인덱스의 항목을 삭제하고 UI에 알림.

### 2단계: 유사 문제 리스트 UI 고도화

- `6_related_question_module.dart` 수정:
    - `_buildRelatedQuizCard` 내부에 삭제 버튼(IconButton) 추가.
    - `aiColor`와 조화를 이루는 디자인 적용 (마우스 호버 시 강조 효과 등).

### 3단계: 사용자 경험(UX) 개선

- 삭제 버튼 클릭 시 별도의 컨펌 없이 즉시 삭제 (빠른 편집 위주).
- 목록이 비었을 때의 안내 메시지 확인.

### 4단계: 최종 통합 테스트 및 검증

- 인라인 이미지 표시, 힌트 그룹화, 유사 문제 삭제 기능이 모두 통합된 화면 테스트.
- 전체적인 레이아웃 균형 및 테마 일관성 점검.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Related Quiz Card Layout**:
    ```
    [ 2023년 1회 5번(과목명) ]  [ 문제 지문 요약... ]  [ (X) 버튼 ]
    ```
    카드 우측 끝에 작은 원형 또는 투명한 삭제 아이콘을 배치하여 콘텐츠 흐름을 방해하지 않으면서도 접근성을 확보.

## 4. IMPLEMENTATION (구현 계획)

- [x] `QuizExtractionStep2ViewModel.removeRelatedQuiz` 구현.
- [ ] `6_related_question_module.dart` 카드 내 삭제 버튼 추가 및 이벤트 연결.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **의도치 않은 삭제**: 관리자의 실수로 삭제할 경우 현재는 '다시 분석' 버튼을 눌러 전체 목록을 갱신해야 복구 가능함. (실무적 허용 범위 내)
- **성능 고려**: 리스트 항목 삭제 시 `notifyListeners()`를 통한 가벼운 위젯 트리 갱신으로 성능 이슈 없음.
