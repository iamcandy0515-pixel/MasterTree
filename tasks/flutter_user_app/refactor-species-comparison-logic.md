# Task: SpeciesComparisonDetailScreen 비즈니스 로직 분리 및 힌트 표시 문제 해결

## 1. 상태 기록 (Plan)

- **목적**:
    1. `SpeciesComparisonDetailScreen` 내부에 섞여 있는 데이터 가공(비즈니스 로직)을 `TreeComparisonProcessor`로 완전히 분리하여 유지보수성 향상.
    2. 데이터 로딩 시 로컬 변수가 아닌 UI 연동 객체(`_tree1Data`, `_tree2Data`)를 올바르게 업데이트하여 '잎', '수피' 힌트가 화면에 표시되지 않는 버그 해결.
- **작업 범위**:
    1. **모델 전용 파일 생성**: `lib/models/tree_comparison_data.dart` (UI 연동용 데이터 클래스).
    2. **컨트롤러/프로세서 생성**: `lib/controllers/tree_comparison_controller.dart` (API 응답 데이터 가공 로직).
    3. **UI 리팩토링**: `lib/screens/species_comparison_detail_screen.dart`에서 중복 가공 로직 제거 및 프로세서 통합.
    4. **검증**: 데이터 로딩 및 상태 변경(탭 전환)이 UI에 즉각 반영되는지 확인.

---

## 2. 실행 (Execute)

- [x] `lib/models/tree_comparison_data.dart` 생성
- [x] `lib/controllers/tree_comparison_controller.dart` 생성 및 `TreeComparisonProcessor` 구현
- [x] `lib/screens/species_comparison_detail_screen.dart` 리팩토링
    - 상단 `TreeComparisonData` 클래스 정의 제거 (models/ import로 대체)
    - `_fetchDetailData` 내부의 가공 로직을 `TreeComparisonProcessor` 호출로 대체
    - `setState` 호출 시 `_tree1Data`, `_tree2Data`를 올바르게 업데이트
- [x] UI 레이아웃 및 탭 동작 재확인 (로그 제거 전 최종 확인)

---

## 3. 사후 점검 (Review)

- **완료된 결과(Result)**:
    - **비즈니스 로직 분리**: `SpeciesComparisonDetailScreen` 내부에 있던 데이터 추출 및 전처리 로직을 `TreeComparisonProcessor`로 완전히 분리했습니다.
    - **모델 정립**: `TreeComparisonData`를 별도 파일로 추출하여 데이터 구조를 명확히 했습니다.
    - **버그 수정**: 데이터가 `_tree1Data`, `_tree2Data` 객체에 저장되지 않아 힌트가 표시되지 않던 문제를 해결했습니다.
    - **유지보수성 향상**: UI 코드가 훨씬 간결해졌으며(약 100라인 이상 감소), 데이터 가공 로직을 단독으로 테스트하거나 수정하기 쉬운 구조가 되었습니다.
    - **힌트 필터링 강화**: '가시 유무: 없음', '관속흔 개수:자료없음' 등 실질적인 정보가 없는 특정 패턴을 출력에서 제외하는 로직을 추가했습니다.

- **향후 문제점 및 리스크 분석(Risk Analysis)**:
    - **이미지 데이터 누락**: `TreeComparisonProcessor`는 데이터가 없을 경우 기본값을 반환하므로, 특정 수종에 '잎'이나 '수피' 이미지가 없는 경우 placeholder가 표시됩니다.
    - **성능**: 현재는 상세 화면 진입 시마다 데이터를 새로 가공합니다. 데이터가 많아질 경우 캐싱 전략을 고려해볼 수 있습니다.
