# 작업계획서: Trees 모듈 최적화 및 고성능 모바일 페이로드 리팩토링

## 1. 개요 (Overview)
`trees.controller.ts`의 역할을 분리하여 200라인 제한을 준수하고, 모바일 앱의 런타임 부하를 줄이기 위한 데이터 경량화(`Field Pruning`) 및 전송 최적화(`Gzip`)를 적용합니다. 폴더 기반 아키텍처로 하위 모듈을 재구성합니다.

## 2. 핵심 구현 전략 (Strategy)
- **모션 기능 분리**: 핵심 CRUD와 데이터 관리(통계/CSV) 기능을 개별 컨트롤러로 분리.
- **모바일 로드 부하 최적화**: API 조회 시 `?minimal=true` 파라미터를 지원하여 필수 데이터만 반환.
- **인프라 최적화**: 서버 레벨에서 **Gzip 압축** 미들웨어를 활성화하여 전송 트래픽 절감.
- **문서화 및 검증**: Swagger 업데이트를 통해 변경된 API 명세를 공유하고 정상 동작 확인.

## 3. 폴더 구조 설계 (Folder Structure)
```text
src/modules/trees/
  ├── controllers/
  │    ├── tree-management.controller.ts (CRUD)
  │    └── tree-data.controller.ts (Stats, CSV, Random)
  ├── services/
  │    ├── trees.service.ts
  │    └── trees-data.service.ts
  ├── trees.routes.ts
  └── trees.dto.ts
```

## 4. To-Do List

### 4.1 인프라 및 기반 작업
- [ ] `compression` 패키지 설치 확인 및 `src/app.ts`에 Gzip 미들웨어 적용
- [ ] 로컬 Git 커밋 실행 (작업 전 백업)

### 4.2 컨트롤러 및 서비스 고도화
- [ ] `src/modules/trees/controllers/` 폴더 생성
- [ ] `tree-management.controller.ts` 생성 (`getAll`, `create`, `update`, `delete` 이관)
- [ ] `tree-data.controller.ts` 생성 (`getStats`, `getRandom`, `importCsv`, `exportCsv` 이관)
- [ ] `getAll` 메서드에 `minimal` 쿼리 파라미터 처리 및 필드 필터링 로직 추가

### 4.3 라우터 및 문서화
- [ ] `trees.routes.ts` 경로 매핑 수정 및 컨트롤러 연결
- [ ] Swagger (OpenAPI) 문서 업데이트 (`minimal` 파라미터 추가 명시)

### 4.4 최종 검증
- [ ] 컴파일 및 린트(Lint) 오류 해결
- [ ] API 호출 테스트 (Postman 또는 cURL 활용)
- [ ] 최종 빌드 확인 및 완료 보고

## 5. 단계별 수행 로그 (Log)
- (작업 시작 시 순차적으로 기록 예정)
