# 🧩 작업 계획서: `past_exam_detail_screen.dart` 최적화 고도화 (Advanced Optimization)

## 1. 개요 (Objective)
-   **대상**: `flutter_user_app/lib/screens/past_exam_detail_screen.dart` (현재 157라인)
-   **목표**: 단순 모듈화를 넘어 **Sliver 구조 도입**으로 메모리 점유율을 낮추고, **UI State 분리**를 통해 불필요한 전체 리빌드(Jank)를 차단함.
-   **준수 규칙**: `DEVELOPMENT_RULES.md` (200줄 제한(1-1), 성능 최적화(3-2)), `FLUTTER_3_7_12_TECH_SPEC.md` (4-1).

## 2. 분석 및 개선 전략 (Strategy)
### 🚨 현 상태 분석
- 기존 위젯 추출로 라인 수는 200줄 미만이나, `SingleChildScrollView` 내부에 모든 도메인이 종속되어 스크롤 및 렌더링 효율이 낮음.
- 이미지 확장 및 정답 선택 시 화면 전체가 리빌드되는 구조임.

### ✨ 개선 핵심 (The Better Proposal)
1.  **Sliver Architecture (60FPS 보장)**: `SingleChildScrollView`를 `CustomScrollView`로 교체하여 상단 렌더링 부하를 하단(유사문제 섹션 등)으로 전이시키지 않음.
2.  **Partial UI Rebuild (메모리 절감)**: `isExpanded`와 같은 UI 전용 상태를 메인 스크린에서 분리하여 렌더링 스레드 부하 경감.
3.  **Encapsulated Logic (관심사 분리)**: 앱바의 동기화 로직과 네비게이션 제어를 별도 `Handler`로 캡슐화.

## 3. To-Do List 및 단계별 실천 계획

### Phase 1: 사전 준비 및 기저 작업
- [ ] **[Git]** 현재 소스 로컬 커밋 수행 (`pre-opt-past-exam-detail`)
- [ ] **[Check]** `PastExamDetailController`의 데이터 흐름 분석 및 UI 종속성 파악

### Phase 2: 레이아웃 엔진 엔진 개편 (Sliver Migration)
- [ ] **[Refactor]** 메인 `build` 내의 `Column` 구조를 `CustomScrollView` + `SliverList`로 전환
- [ ] **[Extract]** `ExamInfoBanner` 및 `QuizContentCard`를 `SliverToBoxAdapter` 대응 위젯으로 최적화
- [ ] **[Extract]** 하위 앱바를 전용 `SliverAppBar` 또는 고정 앱바로 분리 (`parts/past_exam_app_bar.dart`)

### Phase 3: 상태 관리 및 액션 분리 (Logic Refactoring)
- [ ] 이미지 확장용 독립 상태 위젯 개발 (화면 전체 갱신 방지)
- [ ] `syncPendingAttempts` 호출 로직을 전용 `ActionHandler`로 이관
- [ ] **[Check]** 모든 콜백 통신 시 `DEVELOPMENT_RULES.md`의 효율적 통신 원칙(1-2) 준수 확인

### Phase 4: 성능 검증 및 완결성 확인
- [ ] **[Lint]** `flutter analyze` 실행 및 린트 오류 제로화
- [ ] **[Build]** 모바일 기기에서의 스크롤 부드러움 및 메모리 사용량 측정
- [ ] **[Git]** 최종 성과 커밋 및 보고 (`opt-past-exam-detail-complete`)

---

> [!IMPORTANT]
> **위 계획서를 검토해 주시고, 승인이 떨어지기 전까지는 실제 구현을 시작하지 않겠습니다.**
