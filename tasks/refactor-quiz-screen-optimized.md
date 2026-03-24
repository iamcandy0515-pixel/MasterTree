# 🧩 작업 계획서: `quiz_screen.dart` 최적화 및 레이어 분할 (Layered Architecture)

## 1. 개요 (Objective)
-   **대상**: `flutter_user_app/lib/screens/quiz_screen.dart`
-   **목표**: 정오답 피드백 오버레이(Feedback Layer)와 메인 퀴즈 진행 로직(Core Logic)을 분리하여 레이턴시를 최소화하고 가독성을 혁신함.
-   **준수 규칙**: 200줄 제한(1-1), 모듈 간 통신 최적화(1-2), 고정 빌드 명세(4-1).

## 2. 분석 및 개선 전략 (Strategy)
### 🚨 현 상태 분석
- 퀴즈 진행 위젯과 정오답 처리용 피드백 UI가 한 파일에 섞여 있어 복잡도가 높음.
- 애니메이션과 `setState`가 동시에 발생할 경우 프레임 드롭(Jank) 위험이 존재.

### ✨ 개선 핵심 (The Better Proposal)
1.  **Feedback Overlay Migration (Layering)**: 정오답 피드백 UI를 독립적인 `Overlay` 레이어로 추출하여 메인 화면 리빌드 없이도 고품질 애니메이션 구현.
2.  **Isolated Progress Tracking**: 타이머 및 진행률 게이지를 `ValueNotifier` 기반 독립 위젯으로 분리하여 매초 발생하는 리빌드 범위를 최소화.
3.  **Question Fragment Separation**: 문제 데이터 로드 및 렌더링을 캡슐화하여 `QuizScreen` 메인 파일의 책임을 '플로우 제어(Main Flow)'로 한정.

## 3. To-Do List 및 단계별 실천 계획

### Phase 1: 사전 준비 및 기저 작업
- [ ] **[Git]** 현재 소스 로컬 커밋 수행 (`pre-opt-quiz-screen`)
- [ ] **[Check]** `QuizController`와의 인터페이스(정답 확인 함수 등) 정렬 확인

### Phase 2: 레이어 분리 및 위젯 추출 (Modularization)
- [ ] **[Extract]** `parts/quiz_feedback_overlay.dart` 분리 (정오답 연출 전용)
- [ ] **[Extract]** `parts/quiz_timer_progress.dart` 분리 (매초 갱신 영역 격리)
- [ ] **[Optim]** 퀴즈 문제 전환 시 하드웨어 가속 트랜지션 적용 검토 (60FPS 목표)

### Phase 3: 완결성 확인 및 빌드 (Rule 2-3)
- [ ] **[Lint]** `flutter analyze` 실행 및 린트 오류 제로화
- [ ] **[Build]** `flutter build apk --debug` 명령으로 실제 Android 기기에서의 애니메이션 부드러움 확인
- [ ] **[Git]** 최종 성과 커밋 및 보고 (`opt-quiz-screen-complete`)

---

> [!IMPORTANT]
> **위 계획서를 검토해 주시고, 승인을 해주시면 즉시 구현 절차에 착수하겠습니다.**
