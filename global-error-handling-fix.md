# 전역 토큰 만료 401/403 예외 처리 및 자동 로그아웃 (global-error-handling-fix)

## 1. 목적 및 범위 (Plan)

- **목적:**
    1. 관리자 앱(Flutter)에서 백엔드 API 호츨 간 빈번하게 마주할 수 있는 HTTP 401(Unauthorized) 또는 403(Forbidden) 오류 발생 시, 단순히 "삭제 실패 (서버 오류 401)"라고 표기하는 것에 그치지 않기 위함.
    2. 세션이 만료됐음을 인지하면 "로그인이 만료되었습니다. 다시 로그인 해주세요."라는 공통 스낵바 메시지를 출력하고, Supabase `signOut` 후 강제로 LoginScreen 으로 돌려보내는 전역(Global) 자동화 메커니즘을 구성함.
- **범위:**
    - `flutter_admin_app/lib/core/globals.dart` (신규 전역 NavigatorKey 파일)
    - `flutter_admin_app/lib/main.dart` (글로벌 키 등록)
    - `flutter_admin_app/lib/core/api/node_api.dart` (예외 판단 로직 통폐합)

## 2. 작업 내용 (Execute)

- **전역 Navigator Key 도입 (`globals.dart`):**
    - Flutter 앱 특성 상 어떠한 `BuildContext` 에 속해있든지 관계없이 곧장 화면을 벗어나거나 스낵바를 표출하려면 `GlobalKey<NavigatorState>`가 필요하므로, 이 키를 생성하고 `main.dart` 의 `MaterialApp` 최상위 `navigatorKey` 슬롯에 주입하였음.
- **공통 \_checkAuthError() 함수 신설 (`node_api.dart`):**
    - `statusCode` 매개변수를 받아 이 코드가 401 이거나 403 일 경우:
        1. Supabase 로컬 인증 객체를 수동 파기(`signOut()`)함.
        2. 생성해 둔 전역 Context를 가져와 하단 스낵바("로그인이 만료되었습니다. 다시 로그인 해주세요.")를 띄움.
        3. `Navigator.pushAndRemoveUntil()`을 이용해 쌓여있던 모든 화면 층을 파쇄하고 `LoginScreen`으로 단독 스택 이동을 강제함.
    - 이를 각 `NodeApi.getTrees()`, `NodeApi.uploadImage()`, `NodeApi.deleteQuiz()` 등 모든 `http.get/post/delete` API 실패 분기문에 최우선적으로 꽂아 넣음(Injection).

## 3. 사후 점검 (Review)

- **Risk Analysis (향후 문제점 및 리스크 분석):**
    - 앱 전역에서 HTTP 통신 계층에서 예외가 발생할 때 `NodeApi`를 사용하지 않고 개별적으로 `http` 라이브러리를 직접 찔러보거나, 서드파티 라이브러리가 예외를 송출할 때는 이 핸들러가 동작하지 않습니다. 가급적 App 내부에서 Node 서버에 접근할 때는 무조건 `NodeApi`를 경유하거나, Dio 의 `Interceptor` 계층으로 이주(Migration)하는 방안을 고려해볼 수 있습니다 (현재 단계에서는 래퍼 클래스로도 완벽히 커버됩니다).
