# 🧩 [Task] Google Drive 인증 방식 일원화 (JWT/서비스 계정)

## 1. 개요 (Overview)
현재 프로젝트에 혼재된 3가지 인증 방식(API Key, OAuth2, JWT)을 **서비스 계정(JWT) 인증 방식**으로 일원화하여 유지보수 효율성과 보안성을 극대화합니다. `DEVELOPMENT_RULES.md`를 준수하며 시스템의 안정성을 보장합니다.

## 2. 전제 조건 및 준비 (Prerequisites)
- [ ] 0-1. 현재 작업 내용 Git 커밋 및 백업 (`git commit -m "chore: save state before auth unification"`)
- [x] 0-2. 터미널 인코딩 확인 (`chcp 65001`) - 완료
- [x] 0-3. 서비스 계정용 Private Key 확보 (`.env.master` 확인) - 완료

## 3. 전략적 질문 (Socratic Gate)
1. **OAuth2 폐기 가능 여부**: 관리자 개인 계정의 드라이브 전체를 탐색해야 하는 특수한 기능을 제외하고, 모든 추출 및 동기화 작업을 서비스 계정으로 대체해도 문제가 없는가?
2. **프론트엔드 영향**: Flutter 앱에서 `API_KEY`를 직접 사용하여 이미지를 호출하는 부분이 있는지, 있다면 서버 프록시로 대체 가능한가?
3. **배포 환경 고려**: 서비스 계정 키(Private Key)의 경우 보안상 매우 민감하므로, `.env` 분배 외에 CI/CD 환경에서의 관리 전략이 있는가?

## 4. 상세 작업 To-Do List

### Phase 1: 공통 모듈 고도화
- [x] `GoogleDriveAuthService.ts`에 JWT 지원 로직 추가 및 우선순위 조정 - 완료
- [ ] `GoogleDriveAuthService.ts`에서 OAuth2 관련 로직을 `@deprecated` 처리 및 명시적 분리
- [ ] 인증 실패 시 통합 에러 로깅 체계 구축

### Phase 2: 서비스 및 컨트롤러 통합
- [ ] `GoogleDriveFileService.ts`: 생성자에서 API Key 참조 제거 및 JWT 필수화
- [ ] `GoogleDriveFileService.ts`: `downloadFile` 메서드에서 Public Fallback 제거 및 Authenticated Stream 일원화
- [ ] `GoogleDriveService.ts`: 이미지 검색 로직에서 JWT 권한 기반 필터링 최적화

### Phase 3: 도구 및 스크립트 전면 개편
- [ ] `src/scripts/` 내 모든 스크립트(약 20개)의 하드코딩된 JSON 경로 제거
- [ ] 모든 스크립트가 중앙 `googleDriveAuthService`를 통해 인증받도록 리팩토링
- [ ] 스크립트 실행 시 `.env` 로드 확인용 유틸리티 강화

### Phase 4: 정합성 체크 및 마무리
- [ ] `flutter analyze`를 통한 프론트엔드 영향도 체크
- [ ] `.env.master`에서 불필요해진 OAuth2/API_KEY 항목 제거 및 주석 업데이트
- [ ] 전체 빌드 및 실행 테스트 (API 4000, Admin 4001, User 4002)

## 5. 리스크 관리 (Risk Analysis)
- **권한 유실**: 서비스 계정이 추가되지 않은 폴더에서 파일 접근 실패 가능성 -> `GoogleDriveService.ts`에 명확한 권한 가이드 에러 메시지 구현.
- **소스 정합성**: 대량의 스크립트 수정 시 오타 발생 위험 -> 스크립트별 실행 테스트 수행.
- **보안**: Private Key 노출 주의 -> `.gitignore` 및 보안 가이드 준수.

---
**작업 시작 일시**: 2026-03-13
**담당자**: Antigravity (AI)
