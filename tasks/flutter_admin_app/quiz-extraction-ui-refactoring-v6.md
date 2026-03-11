# Task: Quiz Extraction UI Labels & Upsert Logic Refactoring

## 1. ANALYSIS (연구 및 분석)

- **UI 라벨 일관성 확보**: 사용자의 요청에 따라 모든 모듈의 타이틀과 라벨을 더 명확하고 간결한 용어로 변경.
    - '문제내용' -> '문제'
    - '해설내용' -> '정답과 해설'
    - '힌트 설정' -> '힌트'
    - '정답 및 보기 설정' -> '보기'
    - '유사 기출 문제 추천' -> '유사 기출문제'
- **DB 저장 로직 개선 (Upsert)**:
    - 현재 단건 저장 시 ID가 없으면 무조건 `insert`를 수행하여 중복 데이터(동일 시험/동일 번호)가 발생할 가능성이 있음.
    - **요구사항**: 동일한 연도/회차/과목의 동일한 문제 번호가 이미 존재하면 기존 데이터를 삭제(또는 덮어쓰기)하고 업데이트, 없으면 신규 저장하는 `upsert` 로직 구현.
- **유사 기출문제 데이터 보존**:
    - AI가 분석하여 관리자가 확정한 유사 문제들의 ID 목록을 `related_quiz_ids` 필드에 함께 저장하도록 처리.

## 2. PLANNING (작업 단계별 계획)

### 1단계: UI 라벨 및 타이틀 전면 수정

- `3_question_explanation_module.dart`: 라벨 및 타이틀 변경.
- `4_distractor_module.dart`: 타이틀 변경.
- `5_hint_module.dart`: (이미 '힌트'이나 전체 확인).
- `6_related_question_module.dart`: 타이틀 및 추천 버튼 라벨 변경.
- `7_db_registration_module.dart`: 저장 버튼 하단 요역 정보 라벨 등 확인.

### 2단계: Flutter ViewModel 저장 페이로드 확장

- `QuizExtractionStep2ViewModel.saveCurrentQuizToDbAction` 수정:
    - `_relatedQuizzes` 목록에서 ID만 추출하여 `related_quiz_ids` 필드로 페이로드에 추가.

### 3단계: Backend Upsert 로직 강화

- `nodejs_admin_api/src/modules/quiz/quiz.service.ts`의 `upsertQuizQuestion` 수정:
    - `repoService.upsertQuizQuestion` 대신 `repoService.upsertSingle`을 사용하여 `exam_id` 및 `question_number` 충돌 시 자동으로 덮어쓰도록 변경.
    - 이를 통해 "기존 데이터 존재 시 업데이트, 없으면 인서트" 요구사항 충실히 이행.

### 4단계: 통합 테스트

- 동일 문제 번호로 두 번 저장 시 DB에 하나의 레코드만 유지되는지 확인.
- 유사 기출문제 ID가 정상적으로 저장되고 로드되는지 확인.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Label Palette**: 텍스트 일관성을 위해 모든 모듈 상단 `Text` 위젯의 문자열을 하드코딩된 값에서 교체.
- **Data Integrity**: `ON CONFLICT (exam_id, question_number) DO UPDATE` 전략을 사용하여 원자적인 데이터 정합성 유지.

## 4. IMPLEMENTATION (구현 계획)

- [ ] UI 모듈별 라벨 수정 (3, 4, 6, 7번 모듈).
- [ ] ViewModel 저장 데이터 구성 수정 (`related_quiz_ids` 포함).
- [ ] Backend Service의 단건 저장 로직을 `upsert` 기반으로 변경.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **유사 문제 ID 유효성**: 추천된 유사 문제가 실제 DB에 존재하는 유효한 ID인지 확인 필요 (AI 추천 단계에서 이미 검증됨).
- **데이터 덮어쓰기 주의**: `upsert` 시 누락된 필드가 null로 덮어씌워지지 않도록 페이로드를 완전하게 구성해야 함.
