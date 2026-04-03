# API 호출 시 보안 토큰 적용 및 Base URL 환경 변수 대응 (quiz-management-auth-fix)

## 1. 목적 및 범위 (Plan)

- **목적:**
    1. 기존 `http.delete` 코드를 사용할 때 하드코딩된 `http://localhost:3000` 주소를 제거하고 환경 변수(dotenv)로부터 동적으로 `API_BASE_URL`를 주입받아 유연성을 확보.
    2. 단순 HTTP 호출이 아닌 `Supabase`의 현재 세션에서 `accessToken`을 추출, `Authorization: Bearer <token>` 형태로 HTTP 헤더를 구성하여 서버 사이드의 JWT(verifyAdmin) 인증을 정상적으로 통과할 수 있도록 보안 처리.
- **범위:**
    - `flutter_admin_app/lib/core/api/node_api.dart`
    - `flutter_admin_app/lib/features/quiz_management/screens/quiz_management_screen.dart`

## 2. 작업 내용 (Execute)

- **Flutter 프론트엔드 (NodeApi 싱글톤 확장):**
    - 앱 전역에서 Node 서버와 통신을 담당하는 기존 `NodeApi` 클래스의 `baseUrl` 속성을 수정하여, 하드코딩된 로컬호스트 주소 대신 `dotenv.env['NODE_API_URL']`를 우선 참조하고 실패 시의 fallback으로만 로컬호스트를 사용하게 변경.
    - 해당 클래스 내부의 `deleteQuiz(int id)` 공용 정적(static) 함수를 신설하고, 내부에서 `_getHeaders()`를 호출시켜 자동으로 현재 접속 중인 관리자의 `Bearer <token>`을 헤더에 감싸 요청하도록 중앙화 처리.
- **Flutter 프론트엔드 (UI 연동 교체):**
    - 기존 `quiz_management_screen.dart` 내부에서 직접 호출하던 하드코딩 `http.delete` 구문과 `package:http/http.dart` import를 모두 삭제.
    - 새로 작성한 `NodeApi.deleteQuiz(id)`를 호출하도록 리팩토링.

## 3. 사후 점검 (Review)

- **Risk Analysis (향후 문제점 및 리스크 분석):**
    - NodeApi를 통하면 세션에서 토큰을 추출하게 되지만, 만일 관리자가 토큰이 만료된 상태에서 브라우저 창만 열어놨다면 토큰이 무효화되어 서버에서 HTTP 401/403 응답을 줄 것입니다. 이 부분에 대해 글로벌 프론트엔드 에러 캐칭 및 재로그인 유도 로직이 추가되면 완벽해질 수 있습니다.
