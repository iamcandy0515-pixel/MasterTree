# [복구 계획서] 관리자 대시보드 하단 네비게이션 및 기능 연결

## 1. 개요 (Overview)

관리자 앱의 사용성 강화를 위해 하단 네비게이션 바의 아이템 구성을 최적화하고, 각 아이템(홈, 통계, 사용자, 설정)이 해당 화면으로 정확히 연결되도록 기능을 복구합니다.

## 2. 기존 작업 분석 (Analysis of Existing Plans)

- **`dashboard_nav_fix.md`**: 네비게이션 바가 스크롤 시 사라지는 현상을 해결하기 위해 `Scaffold.bottomNavigationBar`에 고정하는 구조적 수정을 수행함.
- **`admin-dashboard-recovery.md`**: 대시보드 통계 지표에서 유저 정보를 제거하고, 하단 메뉴 구성을 4종(홈, 통계, 사용자, 설정)으로 확정함.

## 3. 상세 복구 계획 (Recovery Strategy)

### A. 하단 네비게이션 아이템 구성 수정

- **홈 (Home)**: 현재 대시보드로 돌아오는 홈 버튼 (아이콘: `Icons.dashboard`)
- **통계 (Statistics)**: 수목 및 기출 통계 요약 화면 연결 (아이콘: `Icons.analytics_outlined`)
- **사용자 (User)**: 사용자 접속 로그 및 입장코드 관리 화면 연결 (아이콘: `Icons.people_outlined`)
- **설정 (Settings)**: 시스템 설정(공지사항, 버전 등) 화면 연결 (아이콘: `Icons.settings_outlined`)

### B. 기능 연결 (Function Connection)

- `_navigateTo` 유틸리티 함수를 활용하여 각 아이템 클릭 시 해당 Screen으로의 라우팅 보장.

```dart
// 홈: 초기화 또는 스택 정리
_buildNavItem(Icons.dashboard, '홈', true, () {}),
// 통계: 통계 화면으로 이동
_buildNavItem(Icons.analytics_outlined, '통계', false, () => _navigateTo(const StatisticsScreen())),
// 사용자: 사용자 조회 화면으로 이동
_buildNavItem(Icons.people_outlined, '사용자', false, () => _navigateTo(const UserCheckScreen())),
// 설정: 설정 화면으로 이동
_buildNavItem(Icons.settings_outlined, '설정', false, () => _navigateTo(const SettingsScreen())),
```

### C. 레이아웃 최적화

- `BottomNavigationBar` 스타일을 사용자 앱과 통일하여 브랜드 일관성 유지.
- 선택된 상태(IsSelected)에 따른 컬러 하이라이트(`primaryColor`) 처리.
- `SafeArea`를 사용하여 하단 노치 영역에서의 가시성 확보.

## 4. 실행 단계 (Execution Steps)

1.  `DashboardScreen`의 `_buildBottomNav` 위젯을 최신 4개 아이템 구조로 업데이트.
2.  각 아이템의 `onTap` 이벤트에 실제 스크린(`StatisticsScreen`, `UserCheckScreen`, `SettingsScreen`) 연결.
3.  하단 네비게이션의 고정 위치(`Scaffold.bottomNavigationBar`) 재검증.

## 5. 기대 효과 및 리스크 (Risk Analysis)

- **기능 일관성**: 관리자가 웹 브라우저나 태블릿을 통해 접속했을 때도 하단 네비게이션이 고정되어 있어 메뉴 이동 효율이 극대화됨.
- **리스크**: 사용자 조회(`UserCheckScreen`) 화면이 아직 준비되지 않았거나 데이터 로딩 오류가 있을 경우를 대비해 스켈레톤 레이아웃 적용 필요.
