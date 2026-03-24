# 🧩 AI 프롬프트 리팩토링 및 기술 호환성 최적화 계획서: QuizPrompts

본 계획서는 `DEVELOPMENT_RULES.md`의 모듈화 원칙과 `FLUTTER_3_7_12_TECH_SPEC.md`의 데이터 규격을 통합 반영하여 작성되었습니다.

## 1. 개요 및 목적
- **작업 대상**: `nodejs_admin_api/src/modules/quiz/ai/quiz.prompts.ts`
- **현 상태**: 264라인 (200줄 초과), 대규모 프롬프트 문자열이 단일 파일에 밀집되어 유지보수성이 낮음.
- **최종 목표**: 프롬프트 기능별 모듈화 및 `Flutter 3.7.12` 앱에서의 한글 렌더링 성능 최적화를 위한 데이터 포맷 규격화(Plain Text 전면 적용).

## 2. 기술 명세 및 개발 규칙 준수 (Rule & Tech Spec)
- **Node.js/TS**: `TypeScript 5.7.3` 환경 무결성 유지.
- **[Spec 1.4] 한글 및 인코딩**: 프롬프트 내에 `MARKDOWN_FORBIDDEN_RULE`을 강화하여 Flutter 3.7.12 모바일 화면에서 한글이 깨지거나 레이아웃이 어긋나지 않도록 **순수 평문(Plain Text)** 응답 규격 강제.
- **[Rule 1-1] 200줄 제한**: 비대한 프롬프트 파일을 `prompts/` 하위 모듈로 완전히 분리하여 각 파일당 150라인 이하로 감축.
- **[Rule 3-1] DRY 원칙**: 중복되는 프롬프트 지침(4단계 해설 가이드 등)을 공통 상수로 추출하여 효율화.

## 3. 상세 To-Do List

### 🟢 1단계: 사전 보안 및 백업 (Rule 0-1, 0-2)
- [ ] 현재 상태 로컬 Git 커밋 (`feat: pre-refactor backup for QuizPrompts`)
- [ ] `src/modules/quiz/ai/prompts/` 신규 하위 디렉토리 생성.
- [ ] 터미널 인코딩 설정 확인 (`chcp 65001`).

### 🟡 2단계: 프롬프트 모듈별 분할 및 추상화 (Rule 1-1, 3-1)
- [ ] **common.ts**: `EXPLANATION_4_STEPS` 지침(풀이순서-공식-적용-정답) 및 `NO_MARKDOWN` 규칙을 공통 상수로 분리.
- [ ] **extraction.ts**: PDF 파싱 및 문제 추출용 대형 프롬프트(`BATCH_EXTRACT` 등) 이동 및 기정의된 규격 최적화.
- [ ] **refinement.ts**: 문제 QA 및 보정(`REVIEW_ALIGNMENT`), 힌트/오답 생성 프롬프트 이동.
- [ ] **utility.ts**: 필터링 및 추천 알고리즘용 보조 프롬프트 이동.

### 🟠 3단계: 통합 엔트리 및 빌드 검증 (Rule 1-1, 2-3)
- [ ] `src/modules/quiz/ai/quiz.prompts.ts` 수정: 하위 모듈 통합 및 재수출(Re-export) 구조로 전환.
- [ ] **[호환성]**: 기존 프롬프트 호출 코드(Service 등)의 수정 없이 동작하도록 인터페이스 정합성 유지.

### 🔴 4단계: 최종 검수 (Rule 3-2)
- [ ] `npm run build`를 통한 컴파일 오류 확인.
- [ ] **[정합성]**: 실제 API 통신 시 분리된 프롬프트가 한글/평문 규격을 유지하여 Flutter 앱에 올바른 데이터를 전달하는지 테스트.

---
**최종 승인 요청**: 위 프롬프트 모듈화 및 기술 사양 준수 계획에 대해 최종 승인을 부탁드립니다. 승인 후 작업을 시작하겠습니다.
