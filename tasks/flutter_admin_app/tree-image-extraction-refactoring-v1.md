# Task: Tree Image Extraction Feature Refactoring (v1)

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 정밀 분석

- **명칭 변경**: '수목소싱관리' 및 '수목 이미지 소싱 관리'를 **'수목 이미지 추출'**로 통합 변경.
- **UI 구조 개편**:
    - 현재: 좌측 리스트, 우측 상세 정보의 Master-Detail (2-Pane) 구조.
    - 변경: 리스트 화면에서 카드를 클릭하면 **별도의 상세 화면**으로 전환되는 방식으로 개편 (Detail 화면 삭제 후 별개 화면 구성).
- **대상 파일**:
    - `dashboard_screen.dart`: 대시보드 내 버튼 레이블 변경.
    - `tree_sourcing_screen.dart`: 메인 리스트 화면으로 변경 및 레이아웃 수정.
    - `tree_sourcing_detail_screen.dart`: 신규 생성 (상세 정보 및 이미지 관리 전용).
    - `species_selection_section.dart`: 클릭 시 화면 이동 로직 추가.

## 2. PLANNING (작업 단계별 계획)

### 1단계: 명칭 및 레이블 수정

- `DashboardScreen`: '수목 이미지 소싱 관리' -> '수목 이미지 추출'로 텍스트 변경.
- `TreeSourcingScreen`: AppBar 타이틀 '수목 소싱 관리' -> '수목 이미지 추출'로 변경.

### 2단계: 상세 화면 신규 생성 (`tree_sourcing_detail_screen.dart`)

- 기존 `TreeSourcingScreen`의 우측 패널(`ImageManagementSection`)을 별도의 Scaffold 화면으로 분리.
- `TreeSourcingViewModel`을 `ChangeNotifierProvider.value`를 통해 공유받아 상태 유지.

### 3단계: 리스트 화면 레이아웃 수정 (`tree_sourcing_screen.dart`)

- `Row` 구조를 제거하고 `SpeciesSelectionSection`만 단독으로 표시되도록 수정.
- 화면 전체 너비를 활용하는 리스트 구조로 변경.

### 4단계: 내비게이션 로직 업데이트 (`species_selection_section.dart`)

- 카드 클릭 시 `vm.setSelectedTree(tree)` 호출 후 `TreeSourcingDetailScreen`으로 `Navigator.push` 수행.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **State Management**: 기존 `TreeSourcingViewModel`을 그대로 활용하되, 상세 화면 진입 시 해당 인스턴스를 넘겨주어 선택된 수목 정보와 이미지 로딩 상태를 공유.
- **Responsive Layout**: 2-Pane에서 Single-Pane으로 변경됨에 따라 모바일 웹 환경에서도 더 쾌적한 사용성 제공.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `dashboard_screen.dart`: 레이블 텍스트 수정.
- [ ] `tree_sourcing_screen.dart`: 레이블 수정 및 2-Pane 레이아웃 제거.
- [ ] `tree_sourcing_detail_screen.dart`: 신규 상세 화면 구현.
- [ ] `species_selection_section.dart`: 내비게이션 로직 추가.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **상태 유실**: 화면 전환 시 `ViewModel`이 초기화되지 않도록 `Provider.value` 패턴 사용 필수.
- **뒤로가기 처리**: 상세 화면에서 작업 완료 후 리스트로 돌아왔을 때 데이터 갱신 상태 확인(이미지 아이콘 업데이트 등).
- **레이아웃 깨짐**: 400px 고정 너비에서 전체 너비로 확장됨에 따라 카드 내부 요소(아이콘 등)의 정렬 상태 재점검.
