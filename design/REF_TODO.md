# 🚀 아키텍처 및 성능 최적화 작업 목록 (Optimization Todo List)

본 문서는 `ADMIN_APP_SPEC.md`에 정의된 **'아키텍처 및 성능 최적화 전략'**을 실현하기 위한 구체적인 작업 목록입니다.

---

## 📅 Phase 1: UI/Logic 분리 (Frontend Refactoring)

데이터 처리와 화면 표시 로직을 분리하여 유지보수성을 높이고 코드를 경량화합니다.

- [ ] **`TreeDetailViewModel` 생성**
    - `TreeDetailScreen`에 혼재된 `TextEditingController` 관리, 유효성 검사, 저장(`_handleSave`) 로직을 ViewModel로 이관.
    - `Provider` 또는 `ChangeNotifier` 패턴 적용.
- [ ] **`TreeDetailScreen` 리팩토링**
    - `StatefulWidget`의 상태 관리 코드를 제거하고, `ViewModel`을 구독(Watch)하는 형태로 변경.
    - UI 코드는 오직 `build()` 메서드 내에서 렌더링에만 집중.

## ⚡ Phase 2: 서버 부하 분산 및 API 고도화 (Backend Optimization)

클라이언트(앱)의 연산 부하를 줄이기 위해 데이터 처리를 서버로 이관합니다.

- [ ] **GET `/api/trees` API 페이징(Pagination) 적용**
    - Query Parameter 추가: `?page=1&limit=20`
    - `limit`과 `offset`을 사용하여 DB에서 필요한 데이터만 조회(`SELECT ... LIMIT 20 OFFSET 0`).
- [ ] **서버 사이드 필터링 및 검색 구현**
    - Query Parameter 추가: `?search=소나무&category=침엽수`
    - 앱 내부 `where` 필터링 로직을 SQL `WHERE` 절 및 `LIKE` 검색으로 대체.
- [ ] **중복 수목 병합(Deduplication) 로직 서버 이관**
    - 현재 앱(`DashboardViewModel`)에서 수행 중인 '이름 기준 병합' 로직을 백엔드 `TreeService`로 이동.
    - 클라이언트는 병합이 완료된 깔끔한 JSON 데이터만 수신.

## 🔄 Phase 3: 클라이언트 연동 및 최적화 (Client Integration)

고도화된 API를 앱에 적용하고 사용자 경험을 개선합니다.

- [ ] **`DashboardViewModel` 업데이트**
    - `getAllTrees()`(전체 조회) 로직을 `fetchTrees(page: 1)`(페이징 조회) 형태로 변경.
    - 스크롤 최하단 도달 시 다음 페이지를 불러오는 **Infinite Scroll** 로직 구현.
- [ ] **검색 기능 최적화 (Debouncing)**
    - 검색어 입력 시 API 요청이 과도하게 발생하지 않도록 **Debounce(예: 500ms 지연)** 적용.

---

## 📝 관리 노트

- **우선순위**: Phase 2 (서버 최적화) -> Phase 3 (클라이언트 연동) -> Phase 1 (구조 리팩토링)
- **목표**: 앱 실행 시 데이터 로딩 속도 **1초 이내** 단축 및 메모리 사용량 **50% 감소**.
