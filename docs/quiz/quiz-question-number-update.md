# Quiz Question Number Update

## Goal

- 프론트엔드와 백엔드를 수정하여 `quiz_questions` 테이블에 문제 번호(`question_number`)를 저장하도록 기능 추가
- 사용자가 선택한 문제 번호 (UI 상단의 동그란 번호, `_selectedQuestion`)가 DB에 정확히 기록되게 하여, 이후 '2013-1의 5번 문제' 등 특정 문제를 완벽하게 조회/정렬할 수 있도록 함.

## Execution Steps

1. **DB 스키마 추가 (Manual Action Required)**:
    - Supabase SQL Editor를 사용하여 `quiz_questions` 테이블에 `question_number` (Integer) 칼럼을 추가해야 함.
    - 해당 작업은 봇이 직접 수행할 수 없으므로 사용자에게 SQL 스크립트를 제공하고 안내함.

2. **Backend 수정 (Node.js API)**:
    - ✅ `nodejs_admin_api/src/modules/quiz/quiz.service.ts` 내의 `upsertQuizQuestion` 로직에 `question_number` 항목이 payload에 매핑되도록 추가 완료.

3. **Frontend 수정 (Flutter App)**:
    - ✅ `flutter_admin_app/lib/features/quiz_management/viewmodels/quiz_extraction_step2_viewmodel.dart`의 `saveToDb` 함수 내에서 API로 전송되는 데이터에 `'question_number': _selectedQuestion`를 포함해서 전송하도록 수정 완료.

## Result & Risk Analysis (MANDATORY AFTER COMPLETION)

- **결과 (Result):**
    - 백엔드와 프론트엔드 코드 수정이 모두 반영되었음. 이제 프론트엔드에서 '문제 등록' 시 선택된 문제 번호를 API에 함께 송신하며, API에서는 이를 `question_number` 항목으로 DB에 전달할 준비가 됨.
- **리스크 분석 (Risk Analysis):**
    - 현재 DB 테이블 구조에 `question_number` 칼럼이 없기 때문에 바로 저장을 시도할 경우 Supabase 측 오류가 발생할 수 있음. 반드시 `ALTER TABLE quiz_questions ADD COLUMN question_number integer;` 구문을 실행하여 칼럼을 추가한 뒤 사용해야 함.
    - 이후 기존 레코드들에 대해 `question_number`를 수동이나 스크립트로 올바르게 업데이트해주면, 이후 필터링 및 조회가 완전히 안정화됨.
