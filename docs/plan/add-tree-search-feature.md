# 📝 [Plan] 수목 등록 화면 - 수목명 기반 정보 조회 기능 추가

이 계획서는 `DEVELOPMENT_RULES.md`를 준수하며, '신규수목 등록' 화면에서 기존에 등록된 수목을 검색하여 폼을 자동으로 채우는 기능을 구현하기 위한 상세 절차를 담고 있습니다.

## 1. 개요
사용자가 '한글 이름'을 입력하고 '조회' 버튼을 누르면, 시스템 DB에서 해당 이름의 수목 정보를 찾아 학명, 구분, 설명 등의 데이터를 현재 폼에 즉시 덮어씁니다. 이는 중복 입력을 줄이고 데이터 일관성을 유지하기 위함입니다.

## 2. 준수 규칙 (DEVELOPMENT_RULES.md 반영)
- **Rule 0-1 (Git 백업)**: 작업 시작 전 현재 변경 사항(`tree_sourcing_viewmodel_detail.part.dart` 등)을 커밋/스태시하여 백업을 확보한다.
- **Rule 1-1 (200줄 제한)**: `AddTreeBasicInfoSection.dart`는 현재 약 174줄이며, 수정 후 200줄을 초과할 경우 하위 위젯(예: `_HeaderWithSearch`)으로 분리한다.
- **Rule 2-1 (To-Do List)**: 아래 단계별 To-Do 항목을 엄격히 준수한다.
- **Rule 3-2 (Lint Check)**: 작업 완료 후 `flutter analyze`를 수행하여 정적 오류를 제거한다.

## 3. 상세 작업 내역 (To-Do List)

### Phase 1: 로직 개발 (ViewModel & Repository)
- [ ] **[T-1]** `AddTreeViewModel`에 검색 상태 관리를 위한 `bool _isSearching` 변수 및 Getter 추가
- [ ] **[T-2]** `AddTreeViewModel`에 `searchTreeByName()` 비동기 메서드 구현
    - [ ] `MasterTreeRepository.getTrees(search: nameKrController.text)` 호출
    - [ ] 검색 결과가 있다면 `scientificNameController`, `descriptionController`, `selectedCategory` 등을 즉시 덮어씀 (Rule: 승인된 2번 답변 반영)
    - [ ] 조회 성공/실패 여부를 위한 UI 피드백 로직 포함
- [ ] **[T-3]** `MasterTreeRepository`에 `minimal: false` 옵션을 지원하여 검색 시 전체 정보를 가져오도록 보완 (필요 시)

### Phase 2: UI 개발 (Widgets)
- [ ] **[U-1]** `AddTreeBasicInfoSection` 헤더의 '기본 정보' 텍스트 우측에 '조회' `TextButton` 및 `Icons.search` 추가
- [ ] **[U-2]** `_isSearching` 상태에 따라 버튼의 로딩 인디케이터 여부 처리
- [ ] **[U-3]** (선택) 수정 후 200줄 초과 시 헤더 영역 위젯 분리 (`widgets/add_parts/add_tree_info_header.dart`)

### Phase 3: 최종 검증
- [ ] **[V-1]** 실제 수목명 입력 후 '조회' 버튼 동작 테스트 (데이터 매핑 확인)
- [ ] **[V-2]** `flutter analyze` 명령을 통한 린트 오류 최종 점검
- [ ] **[V-3]** 작업 완료 후 Git 최종 커밋

## 4. 위험 요소 및 대응
- **데이터 유실**: 덮어쓰기 시 이미 입력한 내용이 사라질 수 있음을 인지 (사용자 승인 완료).
- **네트워크 지연**: 조회 중 로딩 인디케이터를 명확히 노출하여 중복 클릭 방지.
