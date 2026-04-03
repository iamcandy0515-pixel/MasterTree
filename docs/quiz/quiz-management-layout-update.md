# 현재 작업 현황

## [1] 작업 계획

- 목표:
    1. '기출문제 퀴즈 검수' 스크린(`quiz_management_screen.dart`)의 조회 필터 영역에 있던 두꺼운 배경 박스와 테두리를 없애기.
    2. 조회 필터(과목, 연도, 회차)를 콤보 박스 형태가 아닌 심플한 `text combo box(DropdownButtonHideUnderline)`로 변형하기.
    3. AppBar 영역의 스크린 제목('기출문제 퀴즈 검수') 옆으로 필터링 조건들을 가로(Row) 배치하기.
    4. '조회' 버튼 역시 꽉 차는 박스 버튼이 아니라 텍스트 형태의 아이콘 버튼(`TextButton`)으로 컴팩트하게 축소하여 배치.
- 범위:
    - `flutter_admin_app/lib/features/quiz_management/screens/quiz_management_screen.dart`

## [2] 세부 작업 내용

- [x] `quiz-management-layout-update.md` 파일 생성
- [x] 기존 `_buildFilterSection()` 전체 위젯 제거.
- [x] `_buildDropdown`에서 Container 테두리 장식을 버리고 순수 `DropdownButtonHideUnderline`만 반환하도록 수정 (`isExpanded` 옵션 제거).
- [x] `AppBar`의 `title` 속성을 `SingleChildScrollView` 및 `Row` 로 감싸서 "제목 + 드롭다운 3개 + 조회 텍스트 버튼" 구조로 수평 슬라이드/배치 되도록 변경.

## [3] 결과 분석 및 위험 요인

- **결과 (Result):**
    - 화면 상단을 불필요하게 많이 차지하던 두꺼운 필터 박스가 사라지고, 텍스트와 드롭다운이 자연스럽게 묶인 컴팩트한 타이틀 바 디자인으로 개선. 공간 활용이 극대화됨.
- **리스크 분석 (Risk Analysis):**
    - **오버플로우 문제 방지:** 필터들이 스크린 해상도 가로 길이를 넘치게 덮을 잠재적 Overflow를 대비하여 `SingleChildScrollView`로 감싸 좌우로 스크롤 가능하게 처리했습니다. 다만 윈도우 창의 너비가 너무 작아지면 모바일 환경처럼 제목 바로 옆에 딱 붙거나 짤려보일 수 있습니다. (데스크탑/태블릿용 타겟으로 문제없음)
