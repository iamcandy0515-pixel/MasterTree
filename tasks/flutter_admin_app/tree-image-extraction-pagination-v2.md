# Task: Tree Image Extraction List Pagination & Navigation (v2)

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 정밀 분석

- **페이지네이션**: '수목 이미지 추출' 리스트를 한 번에 5건씩만 노출.
- **네비게이션 바**: 카드 리스트 상단에 페이지 이동 컨트롤 추가.
- **기능 구성**:
    - `맨처음 (<<)`: 1페이지로 이동.
    - `이전 (<)`: 이전 페이지로 이동.
    - `페이지 정보`: 현재 페이지 / 총 페이지 표시.
    - `다음 (>)`: 다음 페이지로 이동.
    - `맨마지막 (>>)`: 마지막 페이지로 이동.
- **인터랙션**: 검색어나 필터 변경 시 자동으로 1페이지로 리셋 필요.

## 2. PLANNING (작업 단계별 계획)

### 1단계: ViewModel 페이지네이션 로직 추가 (`tree_sourcing_viewmodel.dart`)

- `_currentPage` 변수 추가 (기본값 0).
- `_itemsPerPage = 5` 고정값 설정.
- `totalPageCount` 게터 추가.
- `paginatedTrees` 게터 추가 (현재 페이지에 해당하는 5개 항목만 반환).
- 페이지 이동 메서드 구현: `goToFirst()`, `goToLast()`, `nextPage()`, `prevPage()`.
- `setSearchQuery` 시 `_currentPage = 0`으로 리셋 로직 추가.

### 2단계: 리스트 화면 상단 네비게이션 구현 (`species_selection_section.dart`)

- `_buildNavigationHeader()` 메서드 추가.
- `[<<]`, `[<]`, `Page X / Y`, `[>]`, `[>>]` 형태의 버튼 레이아웃 구성.
- 버튼의 활성화/비활성화 처리 (첫 페이지에서 `<<`, `<` 비활성화 등).

### 3단계: 리스트 렌더링 수정

- `vm.trees` 대신 `vm.paginatedTrees`를 사용하여 5건만 출력하도록 `ListView.builder` 수정.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **UI 가이드**: 대시보드 테마(primaryColor, surfaceDark)와 조화로운 색상을 사용하되, 텍스트 플로팅 느낌의 깔끔한 버튼 디자인 적용.
- **State Flow**: 사용자가 페이지를 이동할 때마다 `notifyListeners()`를 통해 리스트만 즉각적으로 업데이트.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `tree_sourcing_viewmodel.dart`: 페이지네이션 상태 및 메서드 추가.
- [ ] `species_selection_section.dart`: 상단 네비게이션 UI 추가 및 데이터 소스 연결.
- [ ] 페이지 이동 인터랙션 테스트.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **항목 부족**: 총 항목이 5개 미만일 경우 네비게이션 바 노출 여부 결정 (가이드에 따라 텍스트만 유지하거나 비활성화 처리).
- **검색 시 동기화**: 검색 결과가 0개일 때의 페이지 표시 처리 (0/0 또는 1/1).
- **성능**: 대량 데이터(78종 이상) 환경에서도 `List.sublist`를 통한 페이지 절삭 처리로 렌더링 부하 최소화.
