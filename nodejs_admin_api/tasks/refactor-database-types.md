# 🧬 Database Types 리팩토링 및 구조 최적화 작업 계획서 (Strategy G, H, I)

이 계획서는 `DEVELOPMENT_RULES.md`의 **Rule 1-1 (200라인 제한)** 및 **Rule 3 (성능 최적화)**을 준수하여, 현재 687라인인 `database.types.ts`를 도메인별 모듈로 파편화하여 관리 효율성을 높이기 위한 공식 가이드입니다.

---

## 1. 리팩토링 및 파편화 전략 (Source Splitting)

### 📂 전략 G: 모듈별 스키마 분산 (`src/types/modules/`)

- **파일**: `quiz.db.ts`, `trees.db.ts`, `auth.db.ts`, `settings.db.ts`.
- **Rule 준수**: 각 모듈에 종속된 테이블 타입을 분리하여 **단일 파일 200라인 미만** 유지.
- **주요 기능**: 특정 도메인의 테이블(`Row`, `Insert`, `Update`) 타입 정의 독립화.

### 🛠️ 전략 H: 공통 데이터 타입 격리 (`common.db.ts`)

- **파일**: `src/types/common.db.ts`
- **Rule 준수**: 전역적으로 사용되는 `Enums`, `Json`, `Functions` 등을 중앙 집중 관리하여 코드 중복 제거 (Rule 3-1).

### 🗺️ 전략 I: 타입 재조립 및 배럴 내보내기 (`database.types.ts`)

- **파일**: `src/types/database.types.ts` 및 `src/types/index.ts`.
- **Rule 준수**: 파편화된 타입들을 다시 하나의 `Database` 인터페이스로 병합하여 기존 인프라(SupabaseClient)와의 정합성 유지 (Rule 0-4).

---

## 2. 세부 구현 To-Do List (Rule 2-1)

### 🗓️ Phase 1: 안정성 확보 및 백업 (Rule 0-1)

- [ ] 현재 `database.types.ts` 상태 로컬 Git 커밋 (`git add . ; git commit -m "pre-refactor database types"`)
- [ ] 파일 인코딩(UTF-16) 체크 및 UTF-8 변환 확인 (Rule 0-2).

### 🧱 Phase 2: 스키마 파편화 실무 (전략 G, H)

- [ ] `src/types/modules/` 디렉토리 생성 및 `common.db.ts` 생성.
- [ ] `trees`, `quizzes`, `auth`, `settings` 관련 테이블 타입을 각 파일로 분리.
- [ ] 전역 `Enums` 및 `Json` 기본 타입 정의 분리.

### 🔗 Phase 3: 타입 재조립 및 배럴 구축 (전략 I)

- [ ] `database.types.ts`를 각 모듈을 임포트하여 병합하는 구조로 재작성.
- [ ] `src/types/index.ts`를 생성하여 통합 내보내기(Barrel Export) 적용.

### 🧪 Phase 4: 정합성 체크 및 종료 (Rule 0-4, 3-2)

- [ ] `supabaseClient.ts` 등 `Database` 참조부의 타입 추론 정상 여부 확인.
- [ ] `linter`를 통한 스타일 및 문법 오류 체크 (**User Rule 준수**).
- [ ] 수정 전/후 타입 정의 수동 대조를 통한 유실 방지 체크 (Rule 0-4).

---

## 3. Socratic Gate (Rule 2-2)

구현 착수 전, 다음 사항에 대해 개발자님의 최종 확인이 필요합니다.

1. **타입 재생성 대응**: `supabase gen types` 실행 시 자동으로 파일을 쪼개주는 간단한 Node.js 스크립트(자동화)를 함께 구축할까요?
2. **Enum 위치**: 전역 `common.db.ts`에 모든 Enum을 모으는 것과, 도메인별 파일로 나누는 것 중 기술적 우선순위를 어디에 두시겠습니까?
3. **타입 임포트 방식**: 통합 배럴(`@/types`)을 통한 임포트와 모듈별 직접 임포트(`@/types/modules/trees`) 중 어느 쪽을 선호하시나요?

---

**주의:** 본 작업은 `DEVELOPMENT_RULES.md`를 최우선 순위로 준수하며 진행됩니다.
승인해 주시면 즉시 Phase 1부터 착수하겠습니다.
