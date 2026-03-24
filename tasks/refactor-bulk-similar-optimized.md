# 🛠️ 작업 계획서: `bulk_similar_management_screen.dart` 고성능 리스트 리팩토링

## 1. 개요 (Overview)
`bulk_similar_management_screen.dart`는 수백 개의 기출문제에 대해 유사문항을 일괄 추출하고 상태를 관리하는 고부하 화면입니다. 현재 `setState` 기반의 전체 리빌드 방식과 UI 내부에 직접 구현된 페이징 로직이 성능 저하의 원인이 되고 있습니다. 이를 **'가상화 페이징 및 부분 갱신'** 구조로 개편합니다.

## 2. 관련 사양 및 규칙 (Rules & Specs)
- **Rule 1-1**: 모든 소스 파일은 200줄을 넘지 않아야 하며, 초과 시 기능별/위젯별로 엄격히 분리(2023.10 적용).
- **Spec 2-1**: Flutter 3.7.12, Dart 2.19.6 환경을 준수함.
- **Spec 4-1**: Java 17(OpenJDK) 환경을 유지하며 빌드 호환성을 확보함.

## 3. 핵심 리팩토링 전략 (Refactoring Strategy)

### A. 상태 관리 방식 개선 (State Management)
- **기존**: `_viewModel.addListener` + `setState` (화면 전체 리빌드) 
- **변경**: `ChangeNotifierProvider` + `Selector` (특정 데이터 변경 시 해당 위젯만 리빌드)

### B. UI와 비즈니스 정제 로직 분리 (Logic Extraction)
- **기존**: `startIndex`, `endIndex`, `pageQuizzes` 계산이 UI `build` 내부에서 수행.
- **변경**: `ViewModel`에서 해당 페이지의 데이터 리스트(`List<Map<String, dynamic>>`)를 완성하여 제공하도록 인터페이스 고도화.

### C. 렌더링 부하 분산 (Rendering Management)
- **리스트 아이템 가상화**: `ListView.builder`의 효율성을 확보하기 위해 개별 아이템 렌더링 고립화.
- **다이얼로그 분리**: 상세 검토용 다이얼로그 호출 로직을 전용 헬퍼 클래스로 외주화.

## 4. 상세 작업 단계 (Action Plan)

### Step 1: 액션 레이어 및 위젯 분리
- `lib/features/quiz_management/screens/widgets/bulk/parts/bulk_list_view.dart` 생성 (리스트 렌더링 전담)
- `lib/features/quiz_management/screens/widgets/bulk/parts/bulk_action_logic.part.dart` (비동기 연산 및 UI 피드백 로직 분리)

### Step 2: 메인 화면 리팩토링 (`bulk_similar_management_screen.dart`)
- `StatelessWidget` 수준의 경량화 (목적: 100라인 이하 감축).
- 영역별 `Selector` 배치를 통한 리빌드 범위 최소화.

### Step 3: 성능 검증 및 빌드 체크
- `flutter analyze`를 통한 린트 오류 제거.
- `flutter build apk --debug`를 통한 Java 17 빌드 무결성 확인.

## 5. 기대 효과 (Expected Results)
- **성능**: 100개 이상의 리스트 아이템 환경에서도 60FPS 스크롤 성능 확보.
- **가독성**: 비즈니스 계산 로직이 UI에서 완전히 제거되어 선언적(Declarative) UI 구조 완성.
- **유지보수**: 200줄 제한 규정 준수로 인한 모듈 간 결합도 하향.

---
**작성자**: Antigravity (Advanced Coding Agent)  
**날짜**: 2026-03-24
