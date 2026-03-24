# 작업계획서: Quiz 모듈 성능 고도화 및 데이터 정합성 리팩토링

## 1. 개요 (Overview)
`quiz.controller.ts`를 주요 도메인별로 분리하고, 모바일 앱의 페이로드 절감을 위해 필터링/페이지네이션 및 썸네일 매핑을 도입합니다. 또한 벌크 작업 시 DB 트랜잭션을 적용하여 데이터 무결성을 보장합니다.

## 2. 핵심 구현 전략 (Strategy)
- **도메인 격리**: Management, Bulk, Search로 컨트롤러를 분리하여 단일 책임 원칙(SRP) 준수.
- **모바일 로드 최적화**: 
    - `minimal` 모드 시 해설(`explanation`) 필드 제거 및 **이미지 썸네일 전용 매핑**.
    - **페이지네이션 및 카테고리 필터링** 도입으로 대량 로딩 원천 차단.
- **데이터 정합성 보장**: 벌크 작업(`Batch`, `Related Mapping`) 시 **DB 트랜잭션** 적용 (All or Nothing).

## 3. 폴더 구조 설계 (Folder Structure)
```text
src/modules/quiz/
  ├── controllers/
  │    ├── quiz-management.controller.ts (단일 CRUD)
  │    ├── quiz-bulk.controller.ts (Batch, Related)
  │    └── quiz-search.controller.ts (Pagination, Filter, Minimal)
  ├── quiz.routes.ts
  ├── quiz.service.ts
  └── quiz.dto.ts
```

## 4. To-Do List

### 4.1 기초 및 백업
- [ ] 로컬 Git 커밋 실행 (작업 전 상태 백업)
- [ ] `src/modules/quiz/controllers/` 디렉터리 생성

### 4.2 컨트롤러 모듈화 및 기능 구현
- [ ] `quiz-management.controller.ts`: 단일 `upsert` 및 `delete` 이관
- [ ] `quiz-bulk.controller.ts`: `upsertQuizBatch`, `upsertRelatedBulk` 이관 및 **트랜잭션 강화**
- [ ] `quiz-search.controller.ts`: `listQuizzes` 고도화 (페이지네이션/필터/`minimal` 필드/썸네일 매핑)

### 4.3 서비스 및 데이터 레이어 강화
- [ ] `quiz.service.ts` 내 벌크 작업 전용 트랜잭션 로직 추가
- [ ] 퀴즈 페이로드 최적화를 위한 데이터 변환 (Thumbnail URL 우선 순위)

### 4.4 라우팅 및 검증
- [ ] `quiz.routes.ts` 수정 및 엔드포인트 재연결
- [ ] Swagger (OpenAPI) 문서 업데이트 (페이지네이션 파라미터 추가)
- [ ] API 호출 테스트 및 최종 빌드 완료 보고

## 5. 단계별 수행 로그 (Log)
- (작업 시작 시 순차적으로 기록 예정)
