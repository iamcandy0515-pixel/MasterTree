# 현재 작업 현황

## [1] 작업 계획

- 목표:
    1. 기출문제 퀴즈 검수(목록 조회) 화면에서 과목명, 년도, 회차 필터 적용 시 데이터가 정상 조회되지 않는 원인 파악 및 해결.
    2. 조회 조건과 DB에 등록된 데이터 포맷 간의 불일치 여부 확인 (예: 연도 타입 불일치, 회차 타입 불일치, 과목명 조인 오류 등).
- 범위:
    - `flutter_admin_app/lib/features/quiz_management/screens/quiz_management_screen.dart`
    - `flutter_admin_app/lib/features/trees/repositories/tree_repository.dart`
    - `nodejs_admin_api/src/modules/quiz/quiz.controller.ts`
    - `nodejs_admin_api/src/modules/quiz/quiz.service.ts`

## [2] 세부 작업 내용

- [x] `quiz-filter-bugfix.md` 파일 생성 (완료)
- [x] 프론트엔드 조회 API(fetchQuizQuestions) 호출 파라미터 확인.
- [x] 백엔드 조회 API(/api/quiz/questions) 쿼리 처리 및 Supabase 조인(quiz_categories, quiz_exams) 로직 확인.
- [x] 원인 도출 후 수정 및 검증.
    - 문제의 원인은 "과목명 조회 조건 String Mismatch" 오류로 판명.
    - DB 등록 시 파일명에 따라 `산림필답(기사,산업기사)` 형태로 저장된 반면, 드롭다운 필터는 `산림필답`을 사용해 완전일치(`eq`) 쿼리로 인해 조회 실패.

## [3] 결과 분석 및 위험 요인

- **결과 (Result):**
    - 추출 후 DB에 저장되는 `quiz_categories.name` 값과 목록 조회 시 드롭다운 값 간의 불일치를 해결하기 위해, 쿼리 구문을 `.eq` (완전일치)에서 `.like('%선택과목%')` (부분일치)로 변경.
    - (안내사항) 유저님께서 염려하신 문제번호(Q1, Q2)와 조회조건의 회차(1, 2)를 서버나 쿼리가 혼동하는 현상은 아닙니다. 조회 조건의 '1'은 DB의 `quiz_exams.round` (int: 1) 데이터와 매핑되어 정상적으로 필터링 되고 있습니다. 데이터가 안나온 이유는 100% '산림필답' 텍스트 불일치 때문이었습니다.
- **리스크 분석 (Risk Analysis):**
    - **문자열 충돌 리스크:** `.like` (부분일치) 구문을 사용했기 때문에, 만약 추후 과목명이 "산림기사"와 "기사" 식의 부분 집합 관계로 등록될 경우 의도치않게 더 넓은 범위의 문제가 한꺼번에 검색될 소지가 있습니다. 현재 "산림/조경/산업안전"으로 prefix 구분이 명확하므로 리스크는 낮으나 유의해야 합니다.
