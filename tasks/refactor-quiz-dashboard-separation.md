# 🧩 작업 계획서: 'QuizDashboardScreen' 최적화 및 분리 리팩토링 (Tech Spec v3.7.12 반영)

이 작업 계획서는 `DEVELOPMENT_RULES.md`의 **200줄 제한 원칙**과 `FLUTTER_3_7_12_TECH_SPEC.md`의 **버전 및 빌드 규격**을 엄격히 준수하여 작성되었습니다.

## 1. 작업 목적 및 기술 규격 (v3.7.12)
- **코드 소형화**: 단일 파일 200라인 준수 및 가독성 확보.
- **성능 최적화**: Flutter 3.7.12 / Dart 2.19.6 환경에 최적화된 `const` 생성자 적극 활용.
- **검증된 라이브러리 사용**: 
    - `fl_chart: ^0.60.0` (격리 및 성능 최적화)
    - `cached_network_image: ^3.2.3` (이미지 로드 시 활용 예정)
    - `shimmer: ^2.0.0` (스켈레톤 로딩 구현용 - 버전 확인 필요)

## 2. 작업 대상 및 상세 로직
- **대상**: `flutter_user_app/lib/features/quiz/screens/quiz_dashboard_screen.dart` (301라인)
- **추출 컴포넌트**:
  1. `StatsSummaryCard`: 요약 통계 위젯 (Null Safety 준수).
  2. `PerformanceTrendsChart`: `fl_chart ^0.60.0` 기반 차트 위젯 (격리 설계).
  3. `QuizModeSelector`: 모드 선택 버튼 컴포넌트 (UI Reusability).
  4. `DashboardSkeleton`: `shimmer` 적용 로딩 레이아웃.

## 3. To-Do List (v3.7.12 Optimized)

### Phase 1: 기반 컴포넌트 추출 및 환경 점검
- [ ] `lib/features/quiz/screens/widgets/dashboard/` 디렉토리 생성
- [ ] `stats_summary_card.dart` 추출 (모바일 가독성 최적화)
- [ ] `performance_trends_chart.dart` 추출 (`fl_chart` 0.60.0 호환성 유지 및 애니메이션 최적화)
- [ ] `quiz_mode_selector.dart` 추출 (모드 버튼 및 인터렉션 캡슐화)

### Phase 2: UX 고도화 (Premium 디자인)
- [ ] `dashboard_skeleton.dart` 생성 (Shimmer 기반, v3.7.12 호환 패키지 확인 후 적용)
- [ ] `RefreshIndicator` 통합 및 Pull-to-Refresh 로직 구현

### Phase 3: 메인 스크린 리팩토링 및 빌드 정합성
- [ ] `quiz_dashboard_screen.dart`를 150라인 이내의 Scaffolding 코드로 개편
- [ ] **[중요]** `const` 키워드 전수 검토 및 적용 (Flutter 3.7.12 렌더링 최적화)
- [ ] `flutter analyze`를 통한 린트 오류 및 `chcp 65001` 기반 빌드 테스트 수행

## 4. 리스크 관리 (Socratic Gate)
- **Q1**: `fl_chart ^0.60.0`의 성능 이슈 대응책은?
    - **A1**: 차트를 별도 `StatelessWidget`으로 격리하여, 전체 화면 리빌드 시 차트 컴포넌트의 불필요한 연산을 차단함.
- **Q2**: Dart 2.19.6 환경에서 주의할 점은?
    - **A2**: Dart 3 전용 문법(Records, Pattern Matching 등)을 사용하지 않도록 주의하며, 기존 Null Safety 안정 버전에 맞춘 코딩 스타일 유지.
- **Q3**: 모바일 로드 부하 방지를 위한 추가 조치는?
    - **A3**: `cached_network_image`와 `shimmer`를 조합하여 네트워크 지연 시에도 UI가 끊김 없이(Smoothly) 동작하도록 구현.

---

> [!IMPORTANT]
> **본 작업 계획서(v3.7.12 Spec 반영본) 승인 후 구현을 시작합니다.**
