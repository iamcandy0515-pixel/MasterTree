# 작업계획서: Users 모듈 인증/관리 분리 및 성능 리팩토링

## 1. 개요 (Overview)
`users.controller.ts`의 역할을 인증(Auth)과 관리(Management)로 명확히 분리하여 200라인 제한을 준수하고, 모바일 앱에서 사용자 목록 로딩 시 발생하는 부하를 줄이기 위한 데이터 최적화(`Field Pruning`) 및 전용 검색 아키텍처를 도입합니다.

## 2. 핵심 구현 전략 (Strategy)
- **인증/관리 컨트롤러 분리**: 도메인별 책임을 분산하여 향후 소셜 로그인 및 MFA 확장이 용이하도록 구성.
- **고성능 데이터 전송**: 사용자 목록 조회 시 `?minimal=true` 파라미터를 지원하여 필수 데이터(Email, Status)만 반환.
- **검색 및 대규모 목록 처리**: 사용자 검색 엔드포인트를 독립적으로 구성하여 성능 모니터링 및 향후 캐싱 적용을 대비.

## 3. 폴더 구조 설계 (Folder Structure)
```text
src/modules/users/
  ├── controllers/
  │    ├── auth.controller.ts (Login, Logout, Me)
  │    └── user-management.controller.ts (List, Search, Status Update, Delete)
  ├── users.routes.ts
  ├── users.service.ts
  └── users.dto.ts
```

## 4. To-Do List

### 4.1 기초 및 백업
- [x] 로컬 Git 커밋 실행 (작업 전 상태 백업)
- [x] `src/modules/users/controllers/` 디렉터리 생성

### 4.2 컨트롤러 모듈화 및 기능 구현
- [x] `auth.controller.ts`: `login`, `getMe` 이관 및 확장 기반 마련
- [x] `user-management.controller.ts`: 
    - [x] `listUsers` 고도화 (`minimal` 모드 추가)
    - [x] `updateUserStatus`, `deleteUser` 이관
    - [x] 전용 검색 로직(Search) 보강

### 4.3 서비스 레이어 고성능화
- [x] `users.service.ts` 내 `listUsers`에서 필드 브루닝(Field Pruning) 로직 적용
- [x] 대규모 DB 조회 시 성능 병목 방지를 위한 쿼리 최적화 (Pagination 정교화)

### 4.4 라우팅 및 검증
- [x] `users.routes.ts` 수정: 인증과 관리 경로를 명확히 구조화
- [x] Swagger (OpenAPI) 문서 업데이트 (유저 검색 및 최적화 파라미터 기술)
- [x] API 호출 테스트 및 최종 빌드 확인

## 5. 단계별 수행 로그 (Log)
- (작업 시작 시 순차적으로 기록 예정)
