# 📝 [작업 계획서] Quiz 모듈 구조 혁신 (전략 A & B 중심)

본 계획서는 `nodejs_admin_api`의 비대한 `quiz.service.ts`를 리팩토링하여 로드 부하를 분산하고 유지보수성을 극대화하기 위한 '전략 A(프롬프트)' 및 '전략 B(레포지토리)' 구축 방안을 다룹니다.

---

## 📅 [Phase 1] 전략 A: Prompt Registry 구축
AI 프롬프트를 비즈니스 로직과 물리적으로 분리하여 관리 효율성을 높입니다.

### 1. 전용 파일 생성
- **대상 경로**: `src/modules/quiz/ai/quiz.prompts.ts`
- **목적**: `quiz.service.ts`에 산재한 긴 프롬프트 문자열을 상수로 정의하고 전문 관리.
- **적용 대상**: `parseRawSource`, `generateDistractor`, `reviewQuizAlignment`, `extractQuizFromPdfBuffer`, `recommendRelated` 등.

### 2. 분리 상세 (예시)
```typescript
// src/modules/quiz/ai/quiz.prompts.ts
export const QuizPrompts = {
  BATCH_EXTRACT: (start: number, end: number) => `... ${start}번 ~ ${end}번 추출 ...`,
  RECOMMEND: (text: string) => `... "${text}"와 유사한 문제 추천 ...`,
  // ... 기타 프롬프트들
};
```

---

## 📅 [Phase 2] 전략 B: Repository Pattern 구축
직접적인 데이터베이스(Supabase) 호출을 캡슐화하여 쿼리 성능과 안정성을 확보합니다.

### 1. 전용 클래스 생성
- **대상 경로**: `src/modules/quiz/quiz.repository.ts`
- **목적**: 서비스 레이어에서 DB 통신 로직을 제거하고, 쿼리 최적화 및 에러 처리를 집중화.

### 2. 주요 구현 메서드
- `findCategoryByName(name: string)`: 중복 카테고리 체크 및 ID 반환.
- `upsertExam(year, round, title)`: 시험 정보 원자성(Atomic) 보장 및 Upsert.
- `upsertQuiz(payload)`: 개별 퀴즈 및 임베딩 데이터 저장.
- `upsertBatchQuizzes(items)`: 대량 저장(Batch) 최적화 로직.

---

## 📊 로드 부하 최적화 포인트 (Load Impact)

1. **메모리(Memory)**: 1,033라인의 거대한 서비스 객체가 메모리를 점유하는 대신, 기능별로 쪼개진 가벼운 객체들이 효율적으로 동작합니다.
2. **커넥션(Connection)**: `QuizRepository`에서 트랜잭션과 벌크 작업을 집중 관리하여 DB 커넥션 병목을 예방합니다.
3. **지연 시간(Latency)**: 프롬프트 최적화를 통해 Gemini 응답 대기 시간을 단축하고, 필요한 데이터만 DB에서 효율적으로 추출합니다.

---

## 🛠️ 작업 도구 및 절차
1. **분석**: `quiz.service.ts`에서 프롬프트와 DB 연동 코드를 추출.
2. **구현**: 위 계획에 맞춰 `quiz.prompts.ts`와 `quiz.repository.ts` 작성.
3. **리팩토링**: `QuizService`가 위 두 파일을 임포트하여 사용하도록 수정(소스 50% 이상 감소 예상).
4. **검증**: 기존 API 기능이 정상 동작하는지 테스트 수행.

---

> [!IMPORTANT]
> 본 계획서는 **검토용**이며, **개발자님의 최종 승인** 후 실제 구현(수술)에 착수하겠습니다.

작성자: Antigravity AI Assistant
작성일: 2026-03-23
