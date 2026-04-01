# 기출문제 DB 등록(Upsert) 기능 분석 및 작업 계획서

## 1. 개요
관리자 앱의 **'기출문제 추출(일괄)'** 화면에서 수행되는 DB 등록 로직이 복합 키(과목, 년도, 회차, 문제번호)를 기반으로 **Upsert(있으면 Update, 없으면 Insert)** 방식으로 동작하는지 확인하고 그 결과를 정리합니다.

## 2. 연쇄적 분석 결과 (Chain of Thought)

### 2.1 프론트엔드 분석 (`Flutter Admin App`)
- **UI 컴포넌트:** `DbRegistrationModule` (`db_registration_module.dart`)
- **데이터 전달:** `QuizExtractionStep2ViewModel`의 `saveToDb`를 호출하며, 이때 `initialSubject`, `initialYear`, `initialRound`, `selectedQuestion` (문제번호)를 필수 키로 포함합니다.
- **API 호출:** `QuizRepository.upsertQuizQuestion` (단건) 또는 `upsertBatch` (일괄)를 통해 백엔드 `/api/quiz/upsert` 또는 `/api/quiz/upsert-batch` 엔드포인트로 데이터를 전송합니다.

### 2.2 백엔드 분석 (`Node.js Admin API`)
- **서비스 계층:** `QuizDataService` (`quiz_data.service.ts`)
    - `ensureExam(subject, year, round)`를 통해 `quiz_exams` 테이블에서 해당 시험의 고유 ID(`exam_id`)를 조회하거나 생성합니다.
- **저장소 계층:** `QuizRepository` (`quiz.repository.ts`)
    - `upsertBatch` 메서드에서 Supabase의 `upsert` 기능을 사용합니다.
    - **핵심 설정:** `.upsert(items, { onConflict: "exam_id, question_number" })`
    - 여기서 `exam_id`는 (과목명 + 년도 + 회차) 정보를 내포하고 있으며, `question_number`는 문제 번호입니다.

### 2.3 분석 결론
- **네, 개발자님.** 분석 결과에 따르면 **(과목명, 년도, 회차, 문제번호)** 가 일치하는 기존 레코드가 있으면 **UPDATE**를 수행하고, 없으면 새로운 레코드를 **INSERT** 하도록 설계되어 있습니다.
- **예시 분석:** (산림산업기사, 2022년, 1회차, 문제 1번)
    - 1단계: `quiz_exams` 테이블에서 '산림산업기사 2022년 1회차'에 해당하는 `exam_id`를 찾습니다.
    - 2단계: `quiz_questions` 테이블에서 해당 `exam_id`와 `question_number: 1` 조합이 있는지 확인합니다.
    - 3단계: 존재하면 해당 행을 수정하고, 없으면 새로 추가합니다.

## 3. 향후 작업 계획 (Step-by-Step)

### [단계 1] DB 제약 조건 최종 확인 (Linter 및 Schema 체크)
- `quiz_questions` 테이블에 `(exam_id, question_number)` 복합 유니크 인덱스가 실제로 적용되어 있는지 Supabase 대시보드 또는 SQL 정의서를 통해 최종 확인합니다. (현재 코드는 이를 전제로 동작 중)

### [단계 2] 예외 상황 테스트
- 이미지 데이터가 포함된 경우 Upsert 시 기존 이미지 URL이 소실되지 않고 `content_blocks` 내에서 정상적으로 유지/갱신되는지 확인합니다.
- 배치 등록(`upsert-batch`) 시 일부 데이터 오류가 전체 트랜잭션에 미치는 영향을 점검합니다.

### [단계 3] UI 개선 (선택 사항)
- Upsert 발생 시 사용자에게 "기존 문제를 업데이트했습니다" 또는 "새 문제를 등록했습니다"와 같은 세분화된 피드백 메시지를 제공하도록 SnackBar 로직을 고도화할 수 있습니다.

---
**작성자:** Antigravity (AI Coding Assistant)
**작성일:** 2026-04-01
