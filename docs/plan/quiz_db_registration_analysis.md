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

### [Phase 1: 사전 준비 및 백업]
- [x] 현재 Git 브랜치 상태 확인 및 백업 (`git commit` 완료)
- [x] 터미널 인코딩 설정 확인 (`chcp 65001`)

### [Phase 2: 코드 정밀 분석 및 검증]
- [x] `nodejs_admin_api/src/modules/quiz/quiz.repository.ts` 내 `upsertBatch` 메서드의 `onConflict` 설정 재확인 (결과: `exam_id, question_number` 기반 동작 확인)
- [x] `QuizDataService.ensureExam` 분석 (과목+년도+회차 조합으로 `exam_id` 고유성 보장 확인)
- [x] 200줄 초과 파일 조사 및 분리: `quiz.repository.ts` (분리 완료: `quiz_query.repository.ts` 생성)

### [Phase 3: 구현 및 최적화]
- [x] **[Rule 1-1]** Repository 소스 분리 (CRUD vs Search) 및 의존성 업데이트 완료
- [ ] **[Risk Fix]** 이미지 데이터 보존 로직 추가 (현재 Upsert 시 `content_blocks` 전체 덮어쓰기로 인한 기존 이미지 소실 위험 대응 필요)
- [x] **[Rule 3-2]** `npm run lint` (`tsc --noEmit`) 실행 및 오류 없음 확인

### [Phase 4: 최종 점검]
- [x] 수정된 소스의 `diff` 분석 (정합성 체크 완료)
- [ ] 최종 결과 보고 및 개발자 승인

---
**작성자:** Antigravity (AI Coding Assistant)
**작성일:** 2026-04-01
**상태:** 데이터 정합성 강화(이미지 보존) 단계 대기 중
