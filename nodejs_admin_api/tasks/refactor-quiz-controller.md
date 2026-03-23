# QuizController 리팩토링 및 로드 부하 분산 작업 계획서 (Strategy D, E, F)

## 0. 개요
`DEVELOPMENT_RULES.md`의 **Rule 1-1 (200라인 제한)** 및 **Rule 3 (성능 최적화)**을 준수하기 위해, 현재 492라인인 `QuizController`를 기능별로 파편화하여 로드 부하를 격리하고 유지보수 성능을 극대화합니다.

---

## 1. 리팩토링 전략 (파편화 및 집중화)

### 🧩 전략 D: 표준 CRUD 컨트롤러 (`quiz.controller.ts`)
*   **파일**: `src/modules/quiz/quiz.controller.ts`
*   **범위**: 기본적인 퀴즈 데이터의 삽입, 수정, 삭제, 조율.
*   **주요 기능**: `listQuizzes`, `upsertQuizQuestion`, `deleteQuiz`, `upsertQuizBatch`, `upsertRelatedBulk`.
*   **효과**: 가장 빈번한 DB 연산을 가볍게 유지하여 API 안정성을 확보합니다.

### 🧠 전략 E: AI 유틸리티 컨트롤러 (`quiz-ai.controller.ts`)
*   **파일**: `src/modules/quiz/quiz-ai.controller.ts`
*   **범위**: AI 프롬프트를 활용한 콘텐츠 생성 및 추천 서비스.
*   **주요 기능**: `parseRawSource`, `generateDistractor`, `generateHints`, `recommendRelated`, `reviewQuizAlignment`.
*   **효과**: 고부하 및 고지연(Latency)이 발생하는 AI 연산을 독립된 컨트롤러로 분리하여 성능 모니터링을 집중화합니다.

### 📥 전략 F: 추출 및 드라이브 컨트롤러 (`quiz-extraction.controller.ts`)
*   **파일**: `src/modules/quiz/quiz-extraction.controller.ts`
*   **범위**: 구글 드라이브 연동 및 외부 PDF 자원 추출 로직.
*   **주요 기능**: `validateDriveFile`, `extractDriveFile`, `extractQuizBatch`.
*   **효과**: 가장 강력한 로드(파일 다운로드 및 대량 배치 파싱)를 별도 컨트롤러로 격리하여 시스템 전체의 부하 분산을 도모합니다.

---

## 2. 세부 구현 로드맵 (To-Do List)

### 🗓️ Phase 1: 사전 작업 및 백업 (Rule 0-1)
- [ ] 현재 소스 코드의 로컬 Git 커밋 및 안정성 확인 (`git add . ; git commit -m "pre-refactor controller"`)
- [ ] `DEVELOPMENT_RULES.md` 기준 누락된 검증 사항 확인.

### 🏃 Phase 2: AI 컨트롤러 분리 (전략 E)
- [ ] `src/modules/quiz/quiz-ai.controller.ts` 생성.
- [ ] `quiz-ai.service.ts` 직접 호출을 통한 콜 스택 최적화 (**Rule 3**).
- [ ] 기존 `QuizController`에서 AI 관련 메서드 이관 및 중복 제거.

### 🚜 Phase 3: 드라이브 및 추출 컨트롤러 분리 (전략 F)
- [ ] `src/modules/quiz/quiz-extraction.controller.ts` 생성.
- [ ] 구글 드라이브 연동 및 PDF 추출 로직 이관.
- [ ] 비정상 동작 시 다른 API에 영향을 주지 않는 예외 처리 강화.

### 🧹 Phase 4: 메인 컨트롤러 경량화 및 조율 (전략 D)
- [ ] `src/modules/quiz/quiz.controller.ts`를 200라인 이하로 축소 (약 150라인 목표).
- [ ] 퀴즈 조회 및 업데이트에 집중된 오케스트레이터로 재배치.

### 🧪 Phase 5: 라우트 맵 수정 및 최종 검증 (Rule 0-4, 2-2)
- [ ] `src/modules/quiz/quiz.routes.ts`에서 신규 컨트롤러 라우팅 등록 및 임포트 수정.
- [ ] `linter`를 통한 스타일 및 문법 오류 체크 (**User Rule 준수**).
- [ ] 개발자(사용자) 최종 승인 및 리액터 완료 보고.

---

## 3. 리스크 및 보안 체크 (Security & Risk)
*   **구글 드라이브 권한**: `GoogleDriveService`의 중복 인스턴스 생성을 피하고 효율적인 토큰 관리를 유지합니다.
*   **데이터 무결성**: 컨트롤러 이관 도중 누락되는 유효성 검사 로직이 없도록 원본 코드와 1:1 대조합니다.

---

**위 작업계획서를 `DEVELOPMENT_RULES.md`에 근거하여 작성하였습니다.** 
개발자님, 이 계획대로 컨트롤러 분리를 진행해도 괜찮을지 확인 부탁드립니다.
 승인해 주시면 즉시 로컬 Git 커밋 후 구현에 착수하겠습니다.
