# 관리자 대시보드 하단 네비게이션 복구 작업

## 작업 기록 (Plan)

- **목적:** 대시보드 하단의 '네비게이션(설정, 통계 등)' 바가 사라지거나 레이아웃 밖으로 밀려 안보이는 현상을 해결하여 항상 고정 배치되도록 복구합니다.
- **범위:** `dashboard_screen.dart` 파일 영역 내 네비게이션 랜더링 위치 관련 구조 수정.

## 실행 (Execute)

- `flutter_admin_app/lib/features/dashboard/screens/dashboard_screen.dart` 파일 수정 반영.
- **수정사항:**
    - 기존에는 `SafeArea` 내의 최상단 `Column` 마지막에 `_buildBottomNav()`를 위치시켜 스크롤뷰나 기기 화면 크기에 따라 하단에서 밀려나거나 오류가 발생할 수 있는 구조였습니다.
    - 이를 제거하고, `Scaffold` 위젯 자체가 기본 제공하는 속성인 `bottomNavigationBar`에 `_buildBottomNav()`를 탑재했습니다. (`bottomNavigationBar: vm.isLoading ? null : SafeArea(child: _buildBottomNav()),`)
    - 바디 영역의 `SafeArea`는 하단(`bottom: false`) 적용을 해제하여, 하단 내비게이션 바와 레이아웃이 겹치지 않게 안정적인 UI 공간을 확보했습니다.

## 사후 점검 및 리스크 분석 (Review & Risk Analysis)

- `Scaffold`의 `bottomNavigationBar` 속성은 어떤 상황에서도 (스크롤 시, 키보드가 올라올 시 등) 화면 최하단에 UI를 띄워주는 안정적인 속성이므로 밀려 사라질 위험이 완전히 해소되었습니다.
- 단, 대시보드가 아닌 다른 하위 페이지(예: 설정, 통계 등) 이동 시에는 네비게이션 바가 공통 컴포넌트(`AdminScaffold` 등)로 사용되지 않고 각각의 Screen 내부에 직접 복사되어 렌더링되고 있어 뷰 간의 통일성 관리가 다소 번거로울 수 있습니다. 추후 여력이 된다면 모든 하위 탭 화면들의 Shell 역할을 하는 공통 네비게이션 스캐폴드 도입을 추천합니다.
