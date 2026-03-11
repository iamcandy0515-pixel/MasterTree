# Task: Quiz Extraction UI Labels, Upsert Logic & Hint Data Mapping Refactoring

## 1. ANALYSIS (연구 및 분석)

### 1-1. UI 라벨 일관성 확보

- 사용자의 요청에 따라 모든 모듈의 타이틀과 라벨을 더 명확하고 간결한 용어로 변경 완료.
    - '문제내용' -> **'문제'**
    - '해설내용' -> **'정답과 해설'**
    - '힌트 설정' -> **'힌트'**
    - '정답 및 보기 설정' -> **'보기'**
    - '유사 기출 문제 추천' -> **'유사 기출문제'**

### 1-2. DB 저장 로직 개선 (Upsert)

- **중복 방지**: 동일 연도/회차/과목의 동일 문제 번호가 이미 존재하면 기존 데이터를 업데이트하고, 없으면 신규 저장하는 `Upsert` 로직을 백엔드 서비스 수준에서 강화(`ON CONFLICT (exam_id, question_number) DO UPDATE`).
- **연관 데이터**: AI가 추천하고 관리자가 확정한 **'유사 기출문제'**의 ID 목록을 `related_quiz_ids` 컬럼에 함께 영구 저장하여 보존.

### 1-3. 힌트(Hint) 데이터 구조 분석 결과

- **물리적 저장**: `quiz_questions` 테이블의 단일 컬럼 `hint_blocks` (타입: `JSONB`)에 저장됨.
- **논리적 관계**: 단일 컬럼 내에 **JSON 배열(Array)** 형태로 여러 개의 힌트 객체를 저장하는 방식.
- **화면-DB 매핑**: 화면의 2개 입력 필드를 ViewModel이 리스트로 묶어 DB의 단일 JSONB 필드로 덮어씌움 (`Upsert` 방식과 일맥상통함).

## 2. PLANNING (작업 단계별 계획)

### 1단계: UI 라벨 및 타이틀 전면 수정 [완료]

- 각 모듈 파일(3, 4, 6번)의 타이틀 및 버튼 라벨을 요청된 명칭으로 일괄 변경.

### 2단계: Flutter ViewModel 저장 페이로드 확장 [완료]

- `saveCurrentQuizToDbAction` 수정: `related_quiz_ids` 필드 추가 및 문제 번호 연결.

### 3단계: Backend Upsert 로직 강화 [완료]

- `nodejs_admin_api`의 `upsertQuizQuestion`을 `upsertSingle` 기반으로 변경하여 데이터 정합성 유지.

### 4단계: 통합 테스트 및 검증 [진행 중]

- 힌트 데이터가 JSONB 배열 형태로 단일 필드에 정상 저장되는지 확인.
- 동일 번호 재저장 시 '기존 데이터 삭제 후 업데이트' 효과가 발생하는지 검증.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **JSONB Flexibility**: 힌트를 1:N 테이블이 아닌 JSONB 배열로 관리함으로써, 향후 힌트 개수 확장에 유연하게 대처.
- **Atomic Operations**: 백엔드에서 `upsert`를 처리함으로써 네트워크 레이턴시 및 데이터 유실 최소화.

## 4. IMPLEMENTATION (구현 상태)

- [x] UI 모듈별 라벨 수정 (3, 4, 6, 7번 모듈).
- [x] ViewModel 저장 데이터 구성 수정 (`related_quiz_ids` 포함).
- [x] Backend Service의 단건 저장 로직을 `Upsert` 기반으로 변경.
- [x] 힌트 데이터 저장 방식 검증 및 분석 완료.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **데이터 덮어쓰기 주의**: `Upsert` 시 특정 필드를 누락하면 해당 필드가 기본값으로 초기화될 수 있으므로, 항상 `payload` 전체를 구성하여 전송해야 함.
- **배열 정렬**: 힌트 저장 시 순서가 중요할 경우 리스트의 인덱스 순서가 보존되어야 함 (현재 구현 방식에서 보존됨).
- **ID 무결성**: 유사 문제 ID 저장 시 해당 ID의 실제 존재 유효성 체크 필요.
