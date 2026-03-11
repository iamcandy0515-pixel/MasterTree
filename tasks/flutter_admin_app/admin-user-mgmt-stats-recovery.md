# [복구 계획서] 관리자 대시보드 사용자 관리 및 통계 고도화 (user-mgmt-stats-refactor)

## 1. 상태 기록 (Plan)

- **목적**:
    1. 관리자 대시보드 본문에서 중복되는 사용자 관리 UI를 정리하여 핵심 지표/메뉴에 집중.
    2. 하단 네비게이션 '사용자' 메뉴를 통해 신규 가입 유저의 승인 프로세스(대기, 승인, 거절)를 구축.
    3. 하단 네비게이션 '통계' 메뉴를 '사용자별 활동 현황' 중심으로 개편하여 활동/비활동 유저를 구분하고 상세 개인별 성과(사용자 앱 연동 로직)를 모니터링.
    4. 모든 사용자 목록에서 관리자(관)와 사용자(사)를 접두어로 구분하여 식별력 강화.

- **작업 범위**:
    - `flutter_admin_app/lib/features/dashboard/screens/dashboard_screen.dart` (본문 UI 정리)
    - `flutter_admin_app/lib/features/dashboard/screens/user_check_screen.dart` (승인 관리 탭 추가)
    - `flutter_admin_app/lib/features/dashboard/screens/statistics_screen.dart` (활동/비활동 탭 기반 유저 목록화)
    - `flutter_admin_app/lib/features/dashboard/repositories/user_repository.dart` (승인 상태 업데이트 API 연결)
    - `nodejs_admin_api/src/modules/users/users.service.ts` (활동 상태 및 승인 필터링 로직 검증)

---

## 2. 상세 작업 계획 (Execute)

### Phase 1: 대시보드 및 공통 UI 정리

- [ ] **대시보드 본문 수정**: `dashboard_screen.dart`에서 '사용자' 조회용 작은 버튼(`_buildSmallHeaderButton`) 및 관련 바로가기 항목을 삭제하여 하단 네비게이션과 기능 중복을 제거.
- [ ] **이름 표기 자동화**: 사용자 목록 렌더링 시 `role` 값에 따라 이름 앞에 `[관]` 또는 `[사]` 접두어가 자동으로 붙도록 `UserCheckViewModel` 및 위젯 수정.

### Phase 2: 사용자 승인 관리 기능 (UserCheckScreen)

- [ ] **3단 탭 UI 구현**: `pending`, `approved`, `rejected` 상태별로 사용자를 필터링하여 보여주는 `DefaultTabController` 도입.
- [ ] **상태 제어 버튼**: `pending` 리스트에서 '승인' 버튼 클릭 시 유저 상태를 `approved`로, '거절' 클릭 시 `rejected`로 변경하는 기능 서버 연동.
- [ ] **서버 연동**: `UserRepository`에 `updateUserStatus(String id, String status)` 전용 메서드 구현.

### Phase 3: 활동 기반 통계 리스트 (StatisticsScreen)

- [x] **사용자 중심 리포트**: 기존 섹션 기반 대시보드에서 '사용자 목록' 중심 UI로 전환.
- [x] **2단 활동 탭 구현**:
    - **활동중인 사용자**: 최근 7일 이내 학습 기록(`lastLogin`)이 있는 유저.
    - **비활동 사용자**: 최근 7일 이내 기록이 없는 유저.
- [x] **통계 로직 연동**: 특정 사용자 선택 시 `UserDetailStatsScreen`으로 이동하여, 사용자 앱에서 사용되는 개인별 퀴즈 정답률/진행도 로직을 그대로 노출. (`/v1/user/stats/performance/:userId` API 호출)

---

## 3. 사후 점검 및 검증 (Review)

- **완료된 결과(Result)**:
    - `StatisticsScreen`을 사용자 목록 기반 UI(활동 탭 2개)로 전면 개편
    - `TreeRepository`에 `getUserPerformanceStats` 추가하여 사용자용 통계 API 연동
- **향후 문제점 및 리스크 분석(Risk Analysis)**:
    - **API 부하**: 현재 500명의 유저를 한 번에 불러와서 프론트엔드에서 최근 접속 7일 기준으로 활동/비활동을 구분하고 있습니다. 사용자가 수만 명으로 늘어날 경우 클라이언트 성능 저하 및 네트워크 부하가 올 수 있으므로, 추후 백엔드에서 pagination과 filter 파라미터(`is_active=true`)를 통해 나눠서 가져오도록 API를 개선해야 합니다.
    - **개인 통계 조회 권한**: `/v1/user/stats/performance/:userId` API는 `verifyAdmin` 미들웨어를 거치도록 라우팅되어 있어 관리자가 열람 가능하지만, 추후 정책 변경 시 열람 권한 검증 로직을 지속적으로 테스트해야 합니다.
