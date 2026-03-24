# 🧩 작업 계획서: `quiz_review_detail_screen.dart` 최적화 및 분석 레이어 분리

## 1. 개요 (Objective)
-   **대상**: `flutter_user_app/lib/screens/quiz_review_detail_screen.dart`
-   **목표**: 정오답 스타일 오프라인화 및 슬리버(Sliver) 아키텍처 도입을 통해 리뷰 화면의 렌더링 성능을 극대화함.
-   **준수 규칙**: 200줄 제한(1-1), 모바일 로드 부하 분산(3-2), 고정 빌드 명세(4-1).

## 2. 분석 및 개선 전략 (Strategy)
### 🚨 현 상태 분석
- 사용자가 선택한 답안과 정답을 매번 `build` 시점에 비교하여 UI 스타일을 결정하고 있음.
- 퀴즈 해설의 양이 방대해질 경우, 스크롤 부하가 발생할 가능성이 큼.

### ✨ 개선 핵심 (The Better Proposal)
1.  **Style Pre-calculation (Offlining)**: UI 스타일 정보를 렌더링 전 단계(ViewModel 또는 Helper)에서 미리 계산하여 CPU 연산 중복 차단.
2.  **Sliver Transition Integration**: `CustomScrollView`를 베이스로 하여 이미지, 문항, 해설 정보를 슬리버 레이어로 구성, 무거운 리소스 로딩 시에도 즉각적인 반응성 확보.
3.  **Partial Rebuild for Explanation**: 해설 텍스트 노출 여부에 따른 리빌드를 전용 위젯 레이어로 고립시켜 애니메이션 프레임 안정화.

## 3. To-Do List 및 단계별 실천 계획

### Phase 1: 사전 준비 및 기저 작업
- [ ] **[Git]** 현재 소스 로컬 커밋 수행 (`pre-opt-quiz-review-detail`)
- [ ] **[Check]** 리뷰 데이터 모델의 스타일 정합성 확인

### Phase 2: 레이어 분리 및 위젯 추출 (Modularization)
- [ ] **[Extract]** `parts/review_option_tile.dart` (정오답 시각화 독립 위젯)
- [ ] **[Extract]** `parts/review_explanation_view.dart` (해설 렌더링 전용 슬리버 레이어)
- [ ] **[Transfer]** 옵션 스타일 결정 로직을 헬퍼 클래스로 이관

### Phase 3: 완결성 확인 및 빌드 (Rule 2-3)
- [ ] **[Lint]** `flutter analyze` 실행 및 린트 오류 제로화
- [ ] **[Build]** 실제 Android 기기에서의 긴 해설 본문 스크롤 감도 확인
- [ ] **[Git]** 최종 성과 커밋 및 보고 (`opt-quiz-review-detail-complete`)

---

> [!IMPORTANT]
> **위 계획서를 검토해 주시고, 승인을 해주시면 즉시 구현 절차에 착수하겠습니다.**
