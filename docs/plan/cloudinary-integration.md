# 📋 Cloudinary 실시간 연동 및 업로드 시스템 개조 계획서 (MasterTreeApp)

본 문서는 DEVELOPMENT_RULES.md를 100% 준수하며, 관리자 앱(Admin App)에서 생성되는 모든 신규 이미지 데이터가 자동으로 Cloudinary에 안전하게 저장되고 최적화되어 서비스되도록 하는 작업 지침입니다.

---

## 🧐 Socratic Gate: 전략적 결정 및 추천안 (승인 필요)

본 프로젝트의 안정성과 성능을 위해 아래의 추천안을 바탕으로 설계되었습니다.

1. **업로드 방식 (Node.js API 중계 유지)**:
    - **추천**: Flutter 앱 직접 업로드 대신 API 서버(1/uploads) 중계 방식을 유지합니다.
    - **장점**: API Secret 보안 강화, 백엔드 한 곳에서 전체 도메인(수목/퀴즈) 업로드 정책 중앙 제어.

2. **최적화 전략 (Cloudinary 전담 최적화)**:
    - **추천**: 서버 측 sharp 연산 부하를 생략하고 Cloudinary URL 파라미터(_auto, q_auto)를 100% 활용합니다.
    - **장점**: 서버 리소스 절감 및 동적 이미지 리사이징 대응능력 극대화.

3. **데이터 정합성 (Strong Atomic Upload)**:
    - **추천**: 이미지 업로드 실패 시 해당 DB 레코드 생성을 원천 차단하는 원자적 트랜잭션 설계를 적용합니다.
    - **장점**: DEVELOPMENT_RULES.md (0-4)의 소스 정합성 및 데이터 유실 방지 규칙 준수.

---

## 🛠️ 작업 대상 및 범위 (Task Scope)

### 🛡️ 1. Node.js Admin API (Backend)

- **수정 파일**: src/modules/uploads/uploads.service.ts
- **구현 내용**:
    - cloudinary.uploader.upload_stream을 활용한 노드 스트림 업로드 구현.
    - 반환 시 자동 최적화 파라미터(_auto, q_auto)가 포함된 URL 생성.
    - deleteFromStorage 함수를 Cloudinary destroy API로 교체하여 리소스 정리 자동화.
- **린트**: sc --noEmit을 통한 문법 체크 필수 수행.

### 📱 2. Flutter Admin App (Frontend)

- **영향도**: 백엔드 API 인터페이스가 동일하므로 프론트엔드 이미지 픽킹/전송 로직의 **코드 수정은 불필요**합니다.
- **검증**: 신규 수목 등록 시 Cloudinary CDN 주소가 정상적으로 로드되는지 확인.

---

## 🚀 상세 실행 단계 (To-Do List)

1. [x] **[0-1] 로컬 Git 백업**: 현재 상태 git stash 또는 commit. (완료)
2. [x] **[Backend] Cloudinary 초기 설정**: .env 변수 로딩 및 SDK 초기화 로직 점검. (완료)
3. [x] **[Backend] UploadService 리팩토링**: Supabase Storage 연동부를 Cloudinary로 1:1 교체. (완료)
4. [x] **[Backend] 린트 체크**: pm run lint 수행하여 타입 에러 제거. (완료)
5. [x] **[Validation] 통합 테스트**: 관리자 앱 -> 서버 업로드 -> Cloudinary 저장 -> DB 기록 확인. (완료)

---

## ⚠️ 주의 사항 및 예외 핸들링

- **200줄 제한**: UploadService 파일이 200줄을 넘지 않도록 기능을 위함시킵니다.
- **에러 핸들링**: 업로드 실패 시 구체적인 Cloudinary 에러 코드를 로깅하고 클라이언트에 400/500 에러를 명확히 반환합니다.

---

**상태**: **완료 (Implementation Completed)**
