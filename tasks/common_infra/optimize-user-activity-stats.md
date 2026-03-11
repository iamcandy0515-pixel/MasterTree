# [작업 계획서] 사용자 활동 통계 API 최적화 및 페이지네이션 연동 (optimize-user-activity-stats)

## 1. 개요 및 목적 (상태 기록 - Plan)

**배경 및 리스크 분석:**
최근 개편된 관리자 대시보드의 '통계' 화면(StatisticsScreen)은 프론트엔드(`StatisticsViewModel`)에서 한 번에 500명의 사용자 목록 데이터를 API로 가져온 뒤, 최근 7일 로그인 기록(`lastLogin`)을 기준으로 활동/비활동 사용자를 클라이언트단에서 연산하여 나누어 보여주고 있습니다.
이는 서비스의 실 사용자가 늘어날수록 다음과 같은 리스크를 수반합니다.

- **클라이언트 성능 및 메모리 저하**: 수만 명의 사용자 리스트를 모바일 기기 메모리에 한꺼번에 싣게 될 시 OOM(Out of Memory) 및 화면 버벅임 원인이 됩니다.
- **네트워크 부하**: 불필요하게 많은 잉여 데이터까지 한 번에 로드하므로 불필요한 트래픽 낭비 및 속도 지연이 발생합니다.

**작업 목적:**

1. 백엔드 사용자 조회 API에서 데이터베이스단 필터링(`is_active`) 및 페이지네이션(Pagination) 기능 고도화
2. 프론트엔드 앱은 무한 스크롤 패턴 등을 활용하여, 사용자가 필요한 시점에 맞춰 N십 개의 데이터를 분할 요청하도록 개선
3. 관리자 전용 통계 권한 검증 로직 재점검

---

## 2. 작업 범위 (Scope)

- 백엔드 (`nodejs_admin_api`):
    - `src/modules/users/users.controller.ts` (API Query Parameters 확장)
    - `src/modules/users/users.service.ts` (`last_login` 기준 supabase 쿼리 필터 추가 로직)
- 프론트엔드 (`flutter_admin_app`):
    - `lib/features/dashboard/repositories/user_repository.dart` (API 조회 시 파라미터 매핑 개선)
    - `lib/features/dashboard/viewmodels/statistics_viewmodel.dart` (활동/비활동 리스트 및 페이지네이션 로직 구현)
    - `lib/features/dashboard/screens/statistics_screen.dart` (ListView 무한 스크롤 이벤트 연동)

---

## 3. 상세 작업 계획 (Execute)

### Phase 1: 백엔드 API 쿼리 조건 처리 추가

- [x] `GET /v1/admin/users` 등에 Query String으로 `?is_active=true` 또는 `?is_active=false`를 받아 처리하도록 `usersController.listUsers`에 로직 추가.
- [x] `usersService.listUsers` 내부에 분기점을 생성하여, `is_active` 파라미터 값에 따라 최근 7일 내의 `last_login`이 기록된 유저와 그렇지 않은 유저를 분리해 Query를 생성하고, `page`와 `limit`을 활용해 페이지네이션화하여 반환.

### Phase 2: 프론트엔드 ViewModels 단 페이지네이션 구조 변경

- [x] `UserRepository.getUsers`의 파라미터를 수정하여 `({int? page, int? limit, bool? isActive})` 형태로 백엔드에 쿼리를 전송하도록 개선.
- [x] `StatisticsViewModel` 내 기존에 배열을 한번에 채우고 가공하던 코드를 삭제.
- [x] `loadActiveUsers({bool refresh = false})`, `loadInactiveUsers({bool refresh = false})` 형태로 별개의 Loading 상태를 구축하고, 무한 스크롤 발생 시 데이터를 기존 `_activeUsers` 리스트의 뒤에 계속 이어붙이는 방식(add)으로 변경.

### Phase 3: 프론트엔드 UI 스크롤 이벤트 및 뷰어 권한 확인

- [x] `StatisticsScreen`의 두 개의 탭 화면(활동 중, 비활동)을 담당하는 Listview에 `ScrollController`를 각각 부착.
- [x] 최하단(Bottom)에 근접하게 스크롤되었을 때 `ViewModel`의 다음 페이지 탐색 함수를 호출. 로딩 상태 스피너 UI 하단 추가.
- [x] `/v1/user/stats/performance/:userId` API의 접근이 관리자인지 검증하는 `verifyAdmin` 미들웨어가 안전하게 동작하고 있는지 검증 완료.

---

## 4. 사후 점검 및 검증 (Review)

- **완료된 결과(Result)**:
    - 백엔드에 `is_active` 필터 및 데이터베이스단 페이지네이션 쿼리 연동 완료 (`total`, `page`, `totalPages` 응답)
    - 기존 통계 뷰모델(`StatisticsViewModel`)에서 한 번에 500개씩 사용자를 부르던 코드를 삭제하고 스크롤 페이지네이션 연동 로직(`loadActiveUsers`, `loadInactiveUsers`) 추가
    - `StatisticsScreen` 내부 사용자 탭에 `RefreshIndicator`와 무한 스크롤이 트리거되는 `ScrollController` 부착 (하단 로딩 스피너 UI 추가) 완료
- **향후 문제점 및 리스크 분석(Risk Analysis)**:
    - 현재 로직은 `last_login` 컬럼만을 기준으로 최근 7일 로그인 여부를 판단하여 클라이언트와 서버 사이의 통신 부하를 대폭 줄였습니다. Auth 시스템에만 기록이 남아있고 `users` 원장 테이블에 연동이 수행되지 않은 극히 일부 계정은 활동내역 조회 시 누락될 수 있으나, 정상적으로 앱(퀴즈, 대시보드)을 이용하는 실 서비스 사용자들은 API 요청 시마다 `last_login`이 갱신되어 이상 없이 필터링됩니다.
    - 관리자용 상세 통계 조회(`/v1/user/stats/performance/:userId`)는 현재 백엔드 라우터에서 `verifyAdmin` 단계를 거침으로써 철저히 보호되고 있습니다. 추후 사용자용 앱에서도 이 상세 통계 데이터를 직접 가져다 쓰게 구현할 경우 관리자용 인증망을 타면 에러가 날 수 있으므로, 해당 시점에는 인증 로직을 분리하는 구조 파악이 요구됩니다.
