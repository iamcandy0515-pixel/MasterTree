# 관리자 대시보드 통계 UI 단일화 (dashboard-stats-unification)

## 1. 상태 기록 (Plan)

- **목적**: 관리자 대시보드의 통계 카드 디자인을 사용자 앱의 대시보드와 동일한 '컴팩트한 텍스트 스타일'로 변경하여 시각적 통일성을 확보하고 하단 메뉴의 공간을 더 확보함.
- **작업 범위**:
    1.  `flutter_admin_app/lib/features/dashboard/screens/dashboard_screen.dart` 수정.
    2.  기존 2x2 `GridView` 형태의 통계 카드를 제거하고, 사용자 앱 스타일의 `FittedBox` + `Row` 기반 통계 바 구현.
    3.  표기 순서: `수목 [n] 종 | 기출 [n] 문 | 유사 [n] 조합 | 유저 [n] 명` 으로 간결하게 배치.

## 2. 실행 (Execute)

- [x] `_buildStatCard` (그리드형) 삭제 및 `_buildTextStatsSection`, `_buildTextStatItem`, `_buildStatDivider` 생성.
- [x] `DashboardViewModel`에서 가져오는 `totalTrees`, `totalQuizzes`, `totalSimilarGroups`, `activeUsers`를 해당 위젯에 바인딩.
- [x] 기존 그리드뷰 영역을 삭제하고 새 위젯을 헤더 아래에 배치.
- [x] 레이아웃 간격 조정 및 린트 에러 방지.

## 3. 사후 점검 (Review)

- **완료된 결과(Result)**: 관리자 앱에서도 사용자 앱과 동일한 "한 줄 통계 정보"를 볼 수 있게 되어 디자인 일관성이 향상되었고, 세로 공간 여백이 크게 확보되어 한 화면에 더 많은 메뉴를 직관적으로 조회할 수 있게 되었습니다.
- **향후 문제점 및 리스크 분석(Risk Analysis)**: 기존의 큰 카드 형태보다 텍스트 위주로 정보 밀도가 높아지므로, 가독성을 위해 적절한 여백과 구분선 스타일을 적용했습니다. 통계 수치 자체가 수만 단위로 커질 경우 `FittedBox`에 의해 폰트 크기가 줄어들 수 있으나 현재 데이터 규모상 리스크가 적습니다.
