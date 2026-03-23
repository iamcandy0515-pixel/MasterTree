# 🧩 [Task] QuizService 구조 분리 및 부하 최적화 (Strategy A & B)

## 📌 개요
`DEVELOPMENT_RULES.md`의 **200라인 제한 원칙(1-1)**에 따라, 현재 1,034라인인 `modules/quiz/quiz.service.ts`를 기능별 전문 모듈로 분리하고, 로드 부하를 최적화하기 위한 전략 A(프롬프트)와 전략 B(레포지토리)를 적용합니다.

---

## 🧐 전략적 질문 (Socratic Gate)
1. **[구조]** 분리된 서비스들 간의 의존성 주입은 어떻게 관리할 것인가? 
   - *답변*: 명시적인 클래스 생성자 주입을 통해 결합도를 낮추고 테스트 용이성을 확보함.
2. **[성능]** 쪼개진 파일들 사이의 과도한 임포트가 런타임 성능에 영향을 주지 않는가?
   - *답변*: Node.js의 모듈 캐싱 덕분에 런타임 성능 영향은 미미하며, 오히려 개별 파일의 메모리 점유율을 관리하기 용이해짐.
3. **[유지보수]** 프롬프트 레지스트리와 서비스 간의 매칭을 어떻게 직관적으로 유지할 것인가?
   - *답변*: 프롬프트 키 이름을 서비스 함수명과 일치시키거나 명확한 도메인 접두사를 사용하여 추적이 가능하게 함.

---

## 📝 To-Do List

### 1단계: 사전 준비 및 백업 (Rule 0-1)
- [ ] 현재 `nodejs_admin_api` 상태 Git 커밋 (`feat: pre-refactor quiz service`)

### 2단계: 전문 레이어 구축 (Strategy A & B)
- [ ] **전략 A (Prompt Registry)**: `src/modules/quiz/ai/quiz.prompts.ts` 생성 및 텍스트 추출 (Rule 1-1)
- [ ] **전략 B (Repository)**: `src/modules/quiz/quiz.repository.ts` 생성 및 Supabase 로직 이관 (Rule 1-1)

### 3단계: 서비스 파편화 (Source Splitting)
- [ ] `QuizAIService`: Gemini 통신 및 정제 로직 전용 서비스 추출 (~200라인)
- [ ] `QuizExtractionService`: PDF 처리 및 배치 연산 전용 서비스 추출 (~200라인)
- [ ] `QuizService` (Orchestrator): 타 서비스 조율 및 컨트롤러 대응 레이어로 축소 (~150라인)

### 4단계: 통합 및 검증 (Rule 1-3, 3-2)
- [ ] `QuizController`의 임포트 경로 업데이트
- [ ] `nodejs_admin_api` 빌드 및 린트 체크 (`npm run lint` 등)
- [ ] 최종 소스 정합성 및 유실 여부 확인 (GitHub 백업본과 비교)

---

## 📊 예상 결과물
- `quiz.service.ts`: 조율 중심의 핵심 서비스 (약 150라인)
- `quiz.repository.ts`: 데이터 접근 전용 클래스 (약 200라인)
- `quiz.ai_service.ts`: AI 연동 전문 서비스 (약 200라인)
- `quiz.extraction_service.ts`: 파일 추출 전문 서비스 (약 200라인)
- `ai/quiz.prompts.ts`: 프롬프트 저장소 (문자열 중심)

---

> [!NOTE]
> 본 작업은 `DEVELOPMENT_RULES.md`를 최우선으로 준수하며, 작업 중 발생하는 모든 에러를 즉시 해결하며 진행합니다.
