# Task: Connect Tree Sourcing to Detailed Extraction Screen

'수목 이미지 추출' 메인 화면에서 수목 선택 시, 고도화된 상세 UI(`tree_sourcing_detail_screen.dart`)를 통해 모든 정보를 관리할 수 있도록 연결 및 UI 구성을 동기화합니다.

## 1. 상태 기록 (Plan)

- [x] `tree_detail_screen.dart`의 UI 및 로직을 `tree_sourcing_detail_screen.dart`로 복사 및 클래스명 정합성 맞춤
- [x] `tree_sourcing_detail_screen.dart`가 `TreeSourcingViewModel`의 `selectedTree`를 활용하거나 생성자를 통해 `Tree` 객체를 받도록 수정
- [x] `SpeciesSelectionSection`의 내비게이션 로직 확인 및 최적화

## 2. 실행 (Execute)

1. `tree_sourcing_detail_screen.dart` 파일 내용을 `tree_detail_screen.dart` 기반으로 전면 교체
2. 클래스명을 `TreeSourcingDetailScreen`으로 변경
3. `SpeciesSelectionSection.dart`에서 `TreeSourcingDetailScreen` 호출 시 필요한 `Tree` 객체 전달 확인

## 3. 사후 점검 (Review)

- [ ] '수목 이미지 추출' -> 수목 클릭 -> 고도화된 상세 화면 정상 진입 여부
- [ ] 데이터 로딩 및 저장 로직 정상 동작 여부
- [ ] Risk Analysis: 기존 `tree_detail_screen.dart`와의 중복 관리 이슈 검토
