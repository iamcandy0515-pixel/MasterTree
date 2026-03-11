# [작업 계획서] 구글 드라이브 OAuth2 인증 전환 및 소스 분리 고도화

## 1. 개요 (Background)
*   **목적**: 구글 드라이브 `API_KEY` 방식을 `OAuth2 Refresh Token` 방식으로 전환하여 보안 및 쓰기 권한을 확보하고, `DEVELOPMENT_RULES.md`의 **200줄 제한 원칙**에 따라 소스 코드를 분리하여 유지보수성을 향상함.
*   **주요 원칙**: 소스 유실 방지, 린트 에러 제로, 200줄 이하 파일 관리.

---

## 2. 작업 전제 조건 (Prerequisites)
- [x] **0-1. Git 백업**: 현재 상태를 로컬 Git에 commit 완료.
- [x] **0-2. 환경 설정**: 터미널 인코딩 확인 (`chcp 65001`).
- [x] **0-3. 환경 변수 검증**: `.env` 내 `GOOGLE_CLIENT_ID`, `SECRET`, `REFRESH_TOKEN` 유효성 최종 확인 완료.

---

## 3. 단계별 작업 내용 (To-Do List)

### Phase 1: 소스 분리 및 모듈화 (Rule 1-1 준수)
- [x] **GoogleDriveService 구조 분석**: 현재 196줄인 `google_drive.service.ts`가 기능을 추가할 경우 200줄을 초과함에 따라 모듈 분리 설계 완료.
- [x] **소스 분리 수행**:
    - `google_drive_auth.service.ts` (신규): OAuth2 인증 및 토큰 관리 전용 완료.
    - `google_drive_file.service.ts` (신규): 파일 검색, 다운로드, 업로드 로직 담당 완료.
    - `google_drive.service.ts` (기존): 통합 인터페이스 및 하위 호환성 유지 완료.
- [x] **Import 정합성**: 분리된 모듈 간의 경로 참조 오류 및 린트 에러 사전 예방 완료.

### Phase 2: OAuth2 인증 및 썸네일 업로드 구현
- [ ] **OAuth2 클라이언트 연동**: `google-auth-library`를 활용한 Refresh Token 로직 구현.
- [ ] **썸네일 서버 사이드 업로드**: 가공된 WebP 이미지를 드라이브에 저장하는 `createFile` 기능 추가.
- [ ] **대용량 파일 경고 우회**: 토큰 기반 인증을 통해 6.8MB 이상 파일의 바이러스 경고 자동 통과.

### Phase 3: 통합 및 빌드 완결성 (Rule 2-3 준수)
- [x] **백엔드 컴파일**: `npm run build`를 실행하여 타입 에러 확인 및 해결 완료.
- [ ] **설정 화면 연동**: 드라이브 권한(쓰기)이 정상적으로 동작하는지 설정 화면에서 테스트.

---

## 4. 품질 관리 및 검착 (Review)

- [ ] **3-2. 린트 및 보안 체크**: 작업 완료 전 `npm run lint` 및 민감 정보 노출 여부 점검.
- [ ] **0-4. 소스 정합성 최종 체크**: 
    - 수정 전/후 파일의 diff 분석.
    - 불필요한 코드(Dead Code) 또는 주석 삭제 여부 확인.
    - 200줄 준수 여부 최종 확인.

---

## 5. 관련 작업 파일 (File Mapping)
| 기능 | 경로 | 상태 |
| :--- | :--- | :--- |
| 인증 모듈 | `nodejs_admin_api/src/modules/external/google_drive_auth.service.ts` | 신규 생성 |
| 파일 모듈 | `nodejs_admin_api/src/modules/external/google_drive_file.service.ts` | 신규 생성 |
| 통합 모듈 | `nodejs_admin_api/src/modules/external/google_drive.service.ts` | 리팩토링 |
| 작업 로그 | `tasks/google-drive-oauth-migration.md` | 현재 파일 |
