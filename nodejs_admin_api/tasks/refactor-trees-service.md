# 🌳 TreeService 리팩토링 및 로드 부하 분산 작업 계획서 (Strategy B, C-1, C-2)

이 계획서는 `DEVELOPMENT_RULES.md`의 **Rule 1-1 (200라인 제한)** 및 **Rule 3 (성능 최적화)**을 준수하여, 현재 485라인인 `TreeService.ts`를 전문 모듈로 파편화하기 위한 공식 가이드입니다.

---

## 1. 리팩토링 전략 (Source Splitting)

### 🏗️ 전략 B: 레포지토리 패턴 (`trees.repository.ts`)
*   **파일**: `src/modules/trees/trees.repository.ts`
*   **Rule 준수**: 데이터 접근 로직(Supabase)을 캡슐화하여 서비스 레이어의 복잡도를 낮춤.
*   **주요 기능**: `trees` 및 `tree_images` 테이블에 대한 CRUD 쿼리 전담.

### 📊 전략 C-1: 데이터 특화 서비스 (`trees-data.service.ts`)
*   **파일**: `src/modules/trees/trees-data.service.ts`
*   **Rule 준수**: 고부하 배치 작업(CSV 임포트/엑스포트) 및 복잡한 통계 연산을 분리하여 메인 로직 보호.
*   **주요 기능**: `getDetailedStats`, `exportTreesCsv`, `importTreesCsv`.

### 🌿 전략 C-2: 경량화된 메인 서비스 (`trees.service.ts`)
*   **파일**: `src/modules/trees/trees.service.ts`
*   **Rule 준수**: **단일 파일 200라인 이하 유지 (목표 150라인)**.
*   **주요 기능**: 비즈니스 로직 조율, 도감 조회(`getAll`), 랜덤 추출(`getRandom`).

---

## 2. 세부 구현 To-Do List (Rule 2-1)

### 🗓️ Phase 1: 안정성 확보 및 백업 (Rule 0-1)
- [ ] 현재 소스 코드 상태 로컬 Git 커밋 (`git add . ; git commit -m "pre-refactor trees service"`)
- [ ] `chcp 65001` 설정을 통한 터미널 인코딩 확인 (Rule 0-2).

### 🗄️ Phase 2: 데이터 레이어 분리 (전략 B)
- [ ] `src/modules/trees/trees.repository.ts` 파일 생성.
- [ ] 모든 `supabase` 직접 호출 함수 이관 및 테스트.

### 📈 Phase 3: 무거운 작업 격리 (전략 C-1)
- [ ] `src/modules/trees/trees-data.service.ts` 파일 생성.
- [ ] CSV 처리(`csv-stringify`, `csv-parse`) 및 통계 연산 로직 이관.
- [ ] 배치 작업 시 발생할 수 있는 메모리/로드 부하 최적화 (Rule 3-1).

### 🛠️ Phase 4: 오케스트레이터 재구축 (전략 C-2)
- [ ] `src/modules/trees/trees.service.ts`를 레포지토리와 데이터 서비스를 호출하는 구조로 재작성.
- [ ] 200라인 초과 여부 최종 점검 (Rule 1-1).

### 🧪 Phase 5: 무결성 검증 및 종료 (Rule 0-4, 3-2)
- [ ] `trees.controller.ts`와 신규 모듈 간의 Import 경로 정합성 체크 (Rule 1-3).
- [ ] 린트(Lint) 에러 수정 및 빌드 완결성 확인 (Rule 2-3).
- [ ] 수정 전/후 소스 Diff 분석을 통한 유실 방지 체크 (Rule 0-4).

---

## 3. Socratic Gate (Rule 2-2)
구현 착수 전, 다음 사항에 대해 개발자님의 최종 확인이 필요합니다.
1. CSV 임포트 시 기존 이미지를 전체 삭제 후 교체하는 방식(Delete-and-Insert)을 유지해도 괜찮을까요?
2. 통계 서비스에서 퀴즈 통계(Mock 데이터)를 실제 테이블 구조가 나올 때까지 별도 파일로 관리할까요?
3. 리팩토링 후 컨트롤러에서 각 서비스를 직접 호출하시겠습니까, 아니면 `trees.service.ts`를 통해서만 접근하시겠습니까?

---
**주의:** 본 작업은 `DEVELOPMENT_RULES.md`를 최우선 순위로 준수하며 진행됩니다.
승인해 주시면 즉시 Phase 1부터 착수하겠습니다.
