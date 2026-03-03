# 수목현황 일람 화면 하단 네비게이션 제거 작업 계획 (remove-tree-list-bottom-nav)

## 1. 개요

Flutter Admin App 내 '수목현황 일람(TreeListScreen)' 화면 하단에 표시되던 네비게이션 바(데이터, 지도, 통계, 설정)를 제거합니다.

## 2. 작업 대상

- 파일: `d:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib\features\trees\screens\tree_list_screen.dart`

## 3. 작업 내용

- `build` 메소드 내부의 `bottomNavigationBar: _buildBottomNav(),` 코드 라인 삭제
- 사용하지 않게 되는 하단 UI 구성 메소드 2개 삭제
    - `Widget _buildBottomNav()`
    - `Widget _buildNavItem(...)`

## 4. 리스크 및 주의사항

- 해당 위젯 코드를 삭제함으로써, 관련된 UI 렌더링 에러가 발생하는지 확인해야 합니다.
- (현재 파일 내에 한정된 메소드이므로 전역적인 부작용은 없을 것으로 예상됩니다.)

위와 같이 코드를 수정하려 합니다. 진행해도 될까요?
