# Task: BulkSimilarManagementScreen 소스 분리 및 모바일 최적화

`lib/features/quiz_management/screens/bulk_similar_management_screen.dart` (558라인)를 기능별로 분리하고, 비즈니스 로직을 뷰모델로 이관하여 **[1-1. 200줄 소스 코드 제한]** 원칙을 준수하고 모바일 기기에서의 로드 부하를 최적화합니다.

## 1. 목적 및 배경 (Objective & Context)
- **소스 코드 비대화**: 현재 550라인 이상의 거대 파일로, 필터링, AI 분석 로직, UI 렌더링이 혼재되어 리소스 관리가 비효율적임. (규칙 1-1 위반)
- **모바일 로드 부하**: 복잡한 상태 업데이트 시 화면 전체가 리빌드되는 구조로, AI 분석 중 성능 저하가 우려됨.
- **유지보수성**: 각 UI 컴포넌트(필터링, 리스트, 상세)가 거대 위젯 내부에 묻혀 있어 기능 확장이 어려움.

## 2. 세부 구현 전략 (Implementation Strategy)
### A. ViewModel 기반 구조 (MVVM 패턴)
- **`BulkSimilarManagementViewModel`**: `Supabase` 데이터 연동, `QuizRepository` 연동, AI 추천 로직, 대량 저장 로직을 화면에서 완전히 분리.
- **상태 관리**: 분석 상태(`analysisStatus`), 추천 데이터(`tempRecommendations`), 진행 상황(`statusMessage`)을 뷰모델에서 관리.

### B. 하위 위젯 추출 (Sub-Widgets)
- **`BulkFilterPanel`**: 과목/연도/회차 드롭다운 및 상태 메시지 렌더링.
- **`BulkActionHeader`**: '일괄 추출', '일괄 저장' 등 실행 버튼 그룹.
- **`BulkPaginationBar`**: 기출 목록 탐색을 위한 페이지네이션 컨트롤.
- **`BulkQuizListItem`**: `Q{번호}` 표시, 분석 상태 아이콘, 문제 본문 노출 및 상세 이동 처리.

### C. 모바일 성능 최적화 (Load Optimization)
- **Static Metadata**: `_subjects`, `_years`, `_rounds` 등을 상수화하거나 뷰모델에서 초기화하여 빌드 타임 오버헤드 축소.
- **Const Constructors**: 하위 위젯들을 `const`로 정의하여 불필요한 Repaint 방지.
- **Partial Rebuild**: 전체 화면 대신 리스트 항목 또는 상태 아이콘 영역만 업데이트되는 구조 전제.

## 3. 작업 일정 및 단계 (Execution Phases)
### Phase 1: 비즈니스 로직 이관
- [ ] `lib/features/quiz_management/viewmodels/bulk_similar_management_viewmodel.dart` 구현
- [ ] 화면의 80% 비즈니스 로직(Supabase API, AI 연계 로직)을 뷰모델로 이관.

### Phase 2: 하위 컴포넌트 추출
- [ ] `lib/features/quiz_management/screens/widgets/bulk/` 생성
- [ ] `BulkFilterPanel`, `BulkActionHeader`, `BulkPaginationBar`, `BulkQuizListItem` 생성.
- [ ] 각 위젯의 복잡도를 100라인 이내로 유지.

### Phase 3: 메인 화면 리팩토링 및 연동
- [ ] `BulkSimilarManagementScreen`을 150라인 이내로 축소.
- [ ] `Provider` 또는 직접 연동 방식을 통해 뷰모델과 하위 위젯 조립.
- [ ] `flutter analyze` 명령어로 무결성 최종 확인.

## 4. To-Do List (DEVELOPMENT_RULES 적용)
- [ ] **[0-1. Git 백업]** 구현 시작 전 현재 상태 로컬 커밋 수행
- [ ] `bulk_similar_management_viewmodel.dart` 구현
- [ ] `bulk_filter_panel.dart` 하위 위젯 구현
- [ ] `bulk_action_header.dart` 하위 위젯 구현
- [ ] `bulk_quiz_list_item.dart` 하위 위젯 구현
- [ ] `bulk_similar_management_screen.dart` 리팩토링 및 150라인 이하 달성
- [ ] **[1-1. 200줄 체크]** 리팩토링 후 모든 파일 소스 라인 수 검증
- [ ] **[3-2. 린트 체크]** `flutter analyze` 스타일/문법 오류 0개 달성
- [ ] **[0-4. 소스 정합성]** `git diff`를 통한 기능 누락 여부 최종 확인
- [ ] **[0-2. Git 최종 커밋]** 완료 후 작업 결과 커밋

## 5. 기대 효과 (Expected Outcomes)
- 코드 복잡도를 낮추어 기능 추가 시 발생할 수 있는 사이드 이펙트 최소화.
- 화면 전체 리빌드를 방지하여 중급 사양 모바일 기기에서의 분석 화면 반응성 향상.
- **DEVELOPMENT_RULES.md**의 모든 정량적 기준 만족.
