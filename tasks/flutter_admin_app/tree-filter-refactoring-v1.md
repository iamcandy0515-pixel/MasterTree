# 작업 계획서: 수목현황 일람 카테고리 필터 UI 개편

## 1. 개요

현재 '전체, 침엽수, 활엽수'로 구성된 단일 스마트 태그 필터를 **1차(침엽수/활엽수)**와 **2차(상록수/낙엽수)**로 분리된 2단 콤보박스(Dropdown) 형태로 개편하여 보다 정밀한 수목 검색 기능을 제공합니다.

---

## 2. 주요 변경 사항

### A. 백엔드 (Node.js API)

- **`TreeService.getAll` 로직 개선**:
    - 기존: 단일 문자열 비교 (`category.ilike.%category%`)
    - 수정: 카테고리 파라미터를 콤마(`,`)로 분리하여 각 태그가 모두 포함된(AND 조건) 결과를 반환하도록 쿼리 수정.
    - 예: `침엽수, 상록수` 선택 시 두 단어가 모두 포함된 수목만 조회.

### B. 관리자 앱 뷰모델 (`TreeListViewModel`)

- **상태 변수 분리**:
    - `selectedCategory` (삭제)
    - `selectedPrimaryCategory` (추가, 기본값: '전체')
    - `selectedSecondaryCategory` (추가, 기본값: '전체')
- **필터링 데이터 정의**:
    - `primaryCategories`: `['전체', '침엽수', '활엽수']`
    - `secondaryCategories`: `['전체', '상록수', '낙엽수']`
- **조회 로직 수정**:
    - `fetchTrees()` 호출 시 두 카테고리 값이 '전체'가 아닌 경우 콤마로 연결하여 Repository에 전달.

### C. 관리자 앱 UI (`TreeListScreen`)

- **필터 영역 개편**:
    - 기존 `ListView` 형태의 스마트 태그 삭제.
    - `Row` 내부에 두 개의 `DropdownButtonFormField` 배치.
    - **디자인 가이드**: `NeoTheme` 스타일을 적용하여 어두운 배경과 Acid Lime 강조색 유지.
- **초기 진입 로직**:
    - `initState` 또는 뷰모델 생성 시 '전체'로 초기화되어 자동 조회됨을 보장.

---

## 3. 세부 작업 단계

### Phase 1: 백엔드 필터 기능 강화

1. `nodejs_admin_api/src/modules/trees/trees.service.ts` 수정.
2. `category.split(',')`를 통해 여러 태그를 순회하며 쿼리에 `ilike` 필터 중첩 적용.

### Phase 2: 뷰모델 상태 및 로직 업데이트

1. `flutter_admin_app/lib/features/trees/viewmodels/tree_list_viewmodel.dart` 수정.
2. `selectedCategory` 관련 로직을 1차/2차 선택값으로 리팩토링.

### Phase 3: UI 개편 및 스타일링

1. `flutter_admin_app/lib/features/trees/screens/tree_list_screen.dart` 수정.
2. `_buildFilterChip`을 제거하고 콤보박스 UI 구현.
3. Dropdown의 스타일(`dropdownColor`, `border`, `textStyle` 등)을 `NeoTheme`에 맞게 조정.

### Phase 4: 최종 테스트

1. 1차 '침엽수' 선택 시 결과 확인.
2. 2차 '상록수' 선택 시 결과 확인.
3. 1차 '침엽수' + 2차 '낙엽수' (은행나무 등) 조합 선택 시 결과 확인.

---

## 4. 기대 효과

- 수목 검색의 정밀도 향상.
- 일관된 필터 인터페이스 제공으로 관리 편의성 증대.
- 향후 카테고리 확장 시 유연한 대응 가능.
