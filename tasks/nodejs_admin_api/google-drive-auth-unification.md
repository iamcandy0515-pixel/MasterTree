# 🧩 [Task] Google Drive 인증 방식 일원화 및 보안 강화 (JWT/서비스 계정)

## 1. 개요 (Overview)
현재 프로젝트에 혼재된 3가지 인증 방식(API Key, OAuth2, JWT)을 **서비스 계정(JWT) 인증 방식**으로 일원화합니다. 특히 보안이 취약한 `.env` 방식의 한계를 극복하기 위해 향후 배포 환경을 고려한 **Multi-Layered 보안 전략**을 작업 계획에 포함합니다.

## 2. 보안 전략 제안 (Production Security Strategy)
배포 환경에서 서비스 계정의 Private Key를 안전하게 관리하기 위해 다음과 같은 단계별 전략을 제안합니다:

1. **[Level 1: Local] 환경 변수 난독화 및 최소화**:
   - `.env.master`에는 실제 키 대신 파일 경로(`GOOGLE_APPLICATION_CREDENTIALS`)만 저장하거나, CI/CD에서 주입받는 방식을 사용합니다.
2. **[Level 2: Deployment] Runtime Secret 주입**:
   - **GCP Secret Manager** 또는 **AWS Secrets Manager**를 사용하여 런타임에 소스 코드 수정 없이 키를 주입받습니다.
   - 키 유출 시 즉시 Rotation(교체)이 가능하도록 설계합니다.
3. **[Level 3: Infrastructure] IAM Role 기반 권한 부여**:
   - (가능한 경우) 키 파일 자체를 사용하지 않고, 서버 엔진(Cloud Run, EC2 등)에 서비스 계정 권한을 직접 부여하는 방식으로 키 관리 부담을 원천 차단합니다.

## 3. 전제 조건 및 준비 (Prerequisites)
- [x] 0-1. 현재 작업 내용 Git 커밋 및 백업 - 완료
- [x] 0-2. 터미널 인코딩 확인 (`chcp 65001`) - 완료
- [x] 0-3. 서비스 계정용 Private Key 확보 - 완료

## 4. 전략적 질문 (Socratic Gate)
1. **Security Tools**: 이미 사용 중인 클라우드(GCP, AWS 등)가 있다면 해당 환경의 전용 Secret Manager를 도입할 의사가 있으신가요?
2. **Migration Scope**: 모든 스크립트를 한 번에 수정할 것인가, 아니면 크리티컬한 API부터 단계적으로 수정할 것인가?
3. **Legacy Fallback**: 과도기적 단계에서 OAuth2 기능을 완전히 제거할 것인가, 아니면 비상용으로 유지할 것인가?

## 5. 상세 작업 To-Do List

### Phase 1: 보안 강화 및 공통 모듈 고도화
- [ ] `GoogleDriveAuthService.ts`: **GCP Default Credentials** 지원 로직 추가 (배포 환경 대응)
- [ ] 키 파일 경로 또는 런타임 환경 변수 우선순위 최적화
- [ ] `.env` 내 보안 주석 강화 및 `SAMPLE_ENV` 최신화

### Phase 2: 서비스 및 컨트롤러 통합
- [ ] `GoogleDriveFileService.ts`: API Key 및 Public Fallback 로직 완전 제거 (보안 강화)
- [ ] `GoogleDriveService.ts`: 서비스 계정 권한 전용 필터링 로직 구현

### Phase 3: 도구 및 스크립트 전면 개편
- [ ] `src/scripts/` 내 하드코딩된 경로 제거 및 중앙 인증 서비스(`GoogleDriveAuthService`) 연동
- [ ] 스크립트 실행 시 보안 가이드라인 준수 확인 로직 추가

### Phase 4: 배포 전략 수립 및 마무리
- [ ] GCP/AWS Secret Manager 연동 가이드 문서 작성
- [ ] `.env.master`에서 불필요한 레거시 키 제거
- [ ] `flutter analyze` 및 서버 빌드 정합성 체크

## 6. 리스크 관리 (Risk Analysis)
- **보안 유실**: Private Key가 Git에 실수로 커밋되는 위험 -> `pre-commit` 훅 또는 CI 스캔 도입 제안.
- **배포 복잡도**: Secret Manager 도입 시 초기 인프라 설정 공수 발생 -> 상세 가이드 문서화로 해결.

---
**작업 시작 일시**: 2026-03-13
**담당자**: Antigravity (AI)
