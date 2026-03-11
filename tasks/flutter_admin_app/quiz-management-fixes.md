# 기출문제 필터링 초기 조건 및 삭제 기능 보완 (quiz-management-fixes)

## 1. 목적 및 범위 (Plan)

- **목적:**
    1. 기출문제 일람 화면 최초 진입 시 필터 조건도 고르지 않았는데 모든 문제가 미리 조회(Fetch)되어 나오는 것을 막고, '조회 조건을 선택해 주세요'라는 안내 메시지 출력.
    2. 기출문제 삭제(`deleteQuiz`) 기능이 UI상에서만 토스트를 띄우고 DB에서 지워지지 않던 문제를 수정 (Flutter 내부의 Supabase Delete 호출이 RLS 정책에 의해 차단되거나 무시되는 현상 타파).
    3. '신규등록' 버튼 클릭 시 기능이 비어있던 부분을 `QuizExtractionScreen`(기출문제 연동 스크린)으로 올바르게 푸시(Navigation) 연결.
- **범위:**
    - `nodejs_admin_api/src/modules/quiz/quiz.service.ts`
    - `nodejs_admin_api/src/modules/quiz/quiz.controller.ts`
    - `nodejs_admin_api/src/modules/quiz/quiz.routes.ts`
    - `flutter_admin_app/lib/features/quiz_management/screens/quiz_management_screen.dart`

## 2. 작업 내용 (Execute)

- **Node.js 백엔드 API (RLS 우회 목적 Delete 라우터 개설):**
    - `quiz.service.ts` 하단에 `deleteQuiz(id: number)` 서비스 로직 작성. (Admin 인증을 통해 쿼리 실행)
    - `quiz.controller.ts` 하단에 `DELETE /api/quiz/:id` Param을 처리하여 서비스를 호출하는 `deleteQuiz` 컨테이너 추가. (응답 완료 시 삭제된 `id` 반환).
    - `quiz.routes.ts` 파일 최하단에 해당 API 접근용 경로(path) 및 관리자 검증(`verifyAdmin`) 미들웨어 포함하여 라우트(Router) 추가. (Admin만 허가 등급)
- **Flutter 프론트엔드 UI/기능:**
    - `initState()`에서 실행되던 `_fetchQuizzes()`를 소거하고, 상태 관리 변수로 `_hasSearched = false;`를 추가.
    - 리스트 조회 버튼이 클릭(조회 시작)되었을 때만 `_hasSearched = true;`가 켜져서 그 때부터 목록 혹은 "데이터 없음" 문구를 보여주게끔 방어 로직 설계.
    - "신규등록" 버튼의 빈 배열 이벤트에 `Navigator.push`로 `QuizExtractionScreen`을 이어줌.
    - 기존 동작하지 않던 Supabase 직결 `.delete()` 구문 대신 `http.delete(Uri.parse('http://localhost:3000/api/quiz/$id'))`를 발신하도록 수정하여 위에서 제작한 백엔드 API를 바로 물림.

## 3. 사후 점검 (Review)

- **Risk Analysis (향후 문제점 및 리스크 분석):**
    - `verifyAdmin`이 요구되는 백엔드 API를 사용하므로, 만약 향후 App의 인증 토큰 체계가 바뀐다면(예: Bearer token 탑재 등) `http.delete` 의 헤더 부분에도 토큰 주입 수정이 필요할 수 있음 (현재는 로컬 구동 테스트).
    - 초기에 한정하여 아무 것도 조회되지 않으므로, 유저가 무심코 아무 옵션을 걸지 않고 조회부터 할 경우 전체 데이터가 페이징(5개씩)되어 쏟아짐. 이대로 써도 무방하나 필요 시 `과목 필터 필수` 등의 제약을 도입할 수 있음.
