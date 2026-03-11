# 작업 계획서: 수목현황 일람 카테고리 필터 UI 개편 및 자동 조회 구현

## 1. 개요

현재 '전체, 침엽수, 활엽수'로 구성된 단일 스마트 태그 필터를 **1차(분류: 침엽수/활엽수)**와 **2차(성상: 상록수/낙엽수)**로 분리된 2단 콤보박스(Dropdown) 형태로 개편합니다. 특히 화면 진입 시 별도의 조작 없이 '전체' 조건으로 데이터를 즉시 불러오는 자동 조회 로직을 포함합니다.

---

## 2. 주요 변경 사항

### A. 백엔드 (Node.js API)

- **`TreeService.getAll` 필터링 강화**:
    - `category` 파라미터가 `침엽수, 낙엽수`와 같이 콤마로 전달될 경우, 각 키워드에 대해 `AND` 조건으로 검색하도록 수정.
    - `query.ilike('category', '%침엽수%').ilike('category', '%낙엽수%')`와 같이 처리하여 정확한 교차 검색 지원.

### B. 관리자 앱 뷰모델 (`TreeListViewModel`)

- **초기 상태 및 자동 조회 로직**:
    - `selectedPrimaryCategory`: `'전체'` (기본값)
    - `selectedSecondaryCategory`: `'전체'` (기본값)
    - **생성자(Constructor)**: 생성 시점에 `fetchTrees()`를 즉시 실행하여 '전체/전체' 조건으로 자동 조회 수행.
- **필터 데이터 정의**:
    - `primaryCategories = ['전체', '침엽수', '활엽수']`
    - `secondaryCategories = ['전체', '상록수', '낙엽수']`
- **검색 파라미터 조합**:
    - 두 값이 모두 '전체'가 아닐 경우 `침엽수, 상록수`와 같이 문자열을 조합하여 API 호출.

### C. 관리자 앱 UI (`TreeListScreen`)

- **콤보박스 UI 구현**:
    - 기존 가로 스크롤 칩 영역을 제거하고, `Row` 내부에 `Expanded`를 사용하여 2개의 `DropdownButtonFormField` 배치.
    - **스타일링**: `NeoTheme` 다크 모드 디자인을 유지하며, Acid Lime 포인트를 활용한 세련된 드롭다운 UI 적용.
- **자동 초기화 확인**:
    - `ChangeNotifierProvider`를 통해 뷰모델이 생성될 때 자동으로 첫 페이지 조회가 이루어지는지 보장.

---

## 3. 세부 작업 단계

### Phase 1: 백엔드 다중 키워드 필터 구현

1. `nodejs_admin_api/src/modules/trees/trees.service.ts`의 `getAll` 메서드 수정.
2. 입력받은 카테고리 문자열을 파싱하여 다중 `ilike` 필터 적용.

### Phase 2: 뷰모델 상태 관리 리팩토링

1. `flutter_admin_app/lib/features/trees/viewmodels/tree_list_viewmodel.dart` 수정.
2. `selectedCategory`를 `primary`/`secondary`로 분리.
3. 데이터 파싱 로직 및 `fetchTrees`의 파라미터 생성 방식 업데이트.

### Phase 3: 필터 UI 개편 및 Acid Lime 테마 적용

1. `flutter_admin_app/lib/features/trees/screens/tree_list_screen.dart`의 필터 영역 수정.
2. 2단 콤보박스 레이아웃 구현 및 선택 변경 시 뷰모델의 필터 메서드 호출.
3. 화면 진입 시 '전체/전체'로 세팅된 콤보박스가 정상 노출되는지 확인.

### Phase 4: 통합 테스트 및 검증

1. **초기 진입**: 화면 로딩 시 78종 전체 데이터가 맞게 나오는지 확인.
2. **복합 필터**: '침엽수' + '낙엽수' 선택 시 '은행나무', '낙엽송' 등이 필터링되는지 확인.
3. **초기화**: 다시 '전체' 선택 시 데이터가 원복되는지 확인.

---

## 4. 기대 효과

- **편의성**: 화면 진입과 동시에 자동으로 조회가 이루어져 사용자 클릭 최소화.
- **정밀도**: 수목의 생태적 특성(분류 + 성상)을 조합한 고도화된 검색 가능.
- **확장성**: 추후 '산림청 분류' 등 3차, 4차 필터 추가 시에도 유연하게 대응 가능.
