# UI와 비지니스 로직 분리 작업 현황 (flutter_user_app)

## 1. 개요

`flutter_user_app`의 유지보수성 향상을 위해 모든 화면의 UI 로직과 비지니스 로직을 분리하는 작업을 수행합니다. `StatefulWidget`의 `State` 클래스는 UI 렌더링 및 이벤트 전달만 담당하고, 실제 로직은 별도의 `Controller` 클래스에서 관리하도록 구현합니다.

## 2. 작업 원칙

- 모든 화면은 전용 `ViewModel` 또는 `Controller` 클래스를 가짐 (예: `QuizManagementViewModel`, `QuizController`)
- **[NEW]** 단순 콜백 방식(`onUpdate: () => setState((){})`)에서 `ChangeNotifier` + `Provider` 패턴으로 전환하여 UI와 로직을 더욱 강력하게 분리
- API 호출 및 데이터 가공은 `ViewModel/Controller` 또는 `Repository/Service` 레이어에서 수행
- `State` 클래스에서는 `Consumer` 또는 `watch/read`를 통해 상태를 구독하도록 구현

## 3. 화면별 작업 현황

| 화면명               | 파일 경로                                           | 컨트롤러명                 |  상태   | 비고                                             |
| :------------------- | :-------------------------------------------------- | :------------------------- | :-----: | :----------------------------------------------- |
| **로그인 화면**      | `lib/screens/login_screen.dart`                     | `AuthController`           | ✅ 완료 | `initState`에서 데이터 로딩 분리                 |
| **허브(메인) 화면**  | `lib/screens/hub_screen.dart`                       | `HubController`            | ✅ 완료 | 초기화 및 상태 관리 분리                         |
| **대시보드 화면**    | `lib/screens/dashboard_screen.dart`                 | `DashboardController`      | ✅ 완료 | 통계 데이터 로깅 및 조회 분리                    |
| **수목 일람 화면**   | `lib/screens/tree_list_screen.dart`                 | `TreeListController`       | ✅ 완료 | 검색, 필터링, 페이징 로직 분리                   |
| **유사종 비교 목록** | `lib/screens/similar_species_list_screen.dart`      | `SimilarSpeciesController` | ✅ 완료 | 데이터 로딩 및 페이징 분리                       |
| **유사종 상세 비교** | `lib/screens/species_comparison_detail_screen.dart` | `TreeComparisonProcessor`  | ✅ 완료 | 이미지 비교 및 데이터 처리 분리                  |
| **수목 식별 퀴즈**   | `lib/screens/quiz_screen.dart`                      | `QuizController`           | ✅ 완료 | `QuizProvider` 의존성 제거 및 로컬 컨트롤러 전환 |
| **퀴즈 결과 화면**   | `lib/screens/quiz_result_screen.dart`               | `QuizResultController`     | ✅ 완료 | 결과 계산 및 매개변수 기반 출력 방식 전환        |
| **기출문제 일람**    | `lib/screens/past_exam_list_screen.dart`            | `PastExamListController`   | ✅ 완료 | 필터링 및 문제 호출 로직 분리                    |
| **기출문제 상세**    | `lib/screens/past_exam_detail_screen.dart`          | `PastExamDetailController` | ✅ 완료 | 문제 데이터 관리 분리                            |

## 4. Admin App (flutter_admin_app) 작업 현황

| 화면명            | 파일 경로                                                          | ViewModel/VM              |  상태   | 비고                                      |
| :---------------- | :----------------------------------------------------------------- | :------------------------ | :-----: | :---------------------------------------- |
| **대시보드**      | `lib/features/dashboard/screens/dashboard_screen.dart`             | `DashboardViewModel`      | ✅ 완료 | MVVM 패턴 적용 완료                       |
| **기출문제 관리** | `lib/features/quiz_management/screens/quiz_management_screen.dart` | `QuizManagementViewModel` | ✅ 완료 | **[Refactored]** ChangeNotifier 적용 완료 |

## 5. 향후 계획

- [x] `flutter_user_app/QuizController`: `ChangeNotifier` 기반으로 마이그레이션 완료
- [x] `flutter_admin_app/QuizManagementScreen`: `QuizManagementViewModel` 도입 및 로직 분리 완료
- [ ] 다른 주요 화면들도 `onUpdate` 콜백 방식에서 `ChangeNotifier` 패턴으로 순차적 전환
- [ ] 전체 코드에 대한 Lint 체크 및 스타일 수정 (진행 중)

---

_최종 업데이트: 2026-02-26_
