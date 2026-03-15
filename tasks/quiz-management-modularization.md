# 🧩 기출문제 관리 화면 리팩토링 및 모듈화 계획서 (Rule-Based QuizManagement Refactoring)

이 계획서는 `flutter_admin_app`의 `quiz_management_screen.dart` 소스를 `DEVELOPMENT_RULES.md` 가이드라인에 따라 **200줄 이하**로 경량화하고, 소스 정합성 및 유실 방지를 최우선으로 하여 리팩토링하기 위한 상세 로드맵입니다.

## 0. 작업 전제 조건 (Prerequisites - Rule 0)
- [x] **Git 백업 (Rule 0-1)**: `git add .` 및 `git commit`을 통해 현재 상태 저장.
- [x] **인코딩 설정 (Rule 0-2)**: `chcp 65001` 터미널 인코딩 확인.
- [x] **현재 상태 분석 (Rule 1-1)**: 현재 545줄인 소스를 분석하여 분리 타겟 정의.

## 1. 리팩토링 및 모듈화 전략 (Modularization Strategy)

### 로직 및 상태 관리 분리
- **ViewModel 도입**: `QuizManagementViewModel.dart`를 생성하여 UI와 비즈니스 로직(Supabase 연동)을 완전히 분리.
- **Selector 패턴 적용**: 부분 리빌드를 통해 성능 및 렌더링 최적화.

### 위젯 모듈화 (Rule 1-1: 200줄 제한 준수)
- **분리 경로**: `lib/features/quiz_management/screens/widgets/quiz_parts/`
- **추출 대상**:
    1. `QuizFilterHeader.dart`: 드롭다운 검색 조건부 UI.
    2. `QuizListItem.dart`: 리스트 항목 카드 및 텍스트 파싱 로직.
    3. `QuizPaginationBar.dart`: 페이지 이동 컨트롤러.
    4. `QuizEmptyState.dart`: 상태별 안내 위젯.

## 2. 작업 To-Do List

### [x] **Phase 1: ViewModel & Base Refactoring**
  - [x] Create `QuizManagementViewModel`
  - [x] Implement Provider state management
  - [x] Auto-fetch implementation
  - [x] Basic ErrorState integration within main screen
  - [x] Git Commit: "Phase 1: Implement QuizManagementViewModel and refactor main screen with Provider"

### [x] **Phase 2: Widget Modularization**
  - [x] Extract `QuizFilterHeader`
  - [x] Extract `QuizListItem`
  - [x] Extract `QuizPaginationBar`
  - [x] Extract `QuizEmptyState`
  - [x] Extract `QuizErrorState` (Separate widget)
  - [x] Git Commit: "Phase 2: Extract modular widgets for QuizManagement"

### [x] **Phase 3: Polishing & Validation**
  - [x] Apply `NeoTheme` & premium UI (shadows, gradients)
  - [x] Ensure all `withValues` usage
  - [x] Final code cleanup (under 200 lines per file)
  - [x] Git Commit: "Phase 3: Apply NeoTheme styling and fix imports"

### Phase 4: 완결성 검증 (Rule 2-3, 3-2)
- [ ] `flutter analyze` 실행 (Lint Error Zero).
- [ ] 전체 기능(조회/삭제/이동) 최종 전수 테스트.
- [ ] **마지막 Git Commit**: "Complete QuizManagementScreen modularization following DEVELOPMENT_RULES.md".

## 3. 정합성 및 완결성 체크리스트 (Rule 0-4)
- [ ] 모든 파일이 200줄 이내로 분리되었는가?
- [ ] Import 경로(부모/자식) 및 린트 에러가 없는가? (Rule 1-3)
- [ ] 실제 빌드 시 에러가 없는가? (Rule 2-3)

---
**에이전트 준수 사항**: 본 계획서 검수 후 **개발자님의 명확한 승인**을 받은 뒤 작업을 시작하며, 구현 전 전략적 질문을 통해 요구사항을 재확인하겠습니다.
