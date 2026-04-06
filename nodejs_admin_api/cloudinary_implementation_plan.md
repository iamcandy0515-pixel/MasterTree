# 📋 Cloudinary 자동 연동 및 이미지 업로드 시스템 개조 계획서

본 계획서는 관리자 앱에서 수목 정보 및 퀴즈 문항 생성 시, 이미지가 자동으로 Cloudinary로 업로드되고 최적화된 CDN URL이 DB에 저장되도록 하기 위한 소스 코드 수정 방안을 담고 있습니다.

---

## 1. 개요
- **목적**: 신규 이미지 데이터 생성 시 Supabase Storage 의존성 제거 및 Cloudinary 자동 연동.
- **주요 전략**: 백엔드(Node.js API)의 공통 업로드 서비스(`UploadService`)를 Cloudinary SDK 기반으로 리팩토링.
- **기대 효과**: 서버 부하 절감(이미지 처리 위임), 데이터 정합성 유지, 로드 속도 최적화(`f_auto, q_auto`).

---

## 2. 소스 코드 수정 대상 및 범위

### 🛡️ [백엔드] Node.js Admin API
| 파일 경로 | 수정 내용 | 비고 |
| :--- | :--- | :--- |
| `src/modules/uploads/uploads.service.ts` | `uploadToStorage` 함수 내 Supabase 업로드 로직을 `cloudinary.uploader.upload_stream`으로 교체. | **핵심 수정 포인트** |
| `package.json` | `cloudinary` 패키지가 이미 설치되어 있으므로 추가 설치 불필요. | 확인 완료 (`v2.9.0`) |
| `.env` | Cloudinary 관련 환경 변수(`CLOUDINARY_CLOUD_NAME` 등) 확인 및 적용. | 확인 완료 |

### 📱 [프론트엔드] Flutter Admin App
| 파일 경로 | 수정 내용 | 비고 |
| :--- | :--- | :--- |
| (API 호출부) | 백엔드 API 엔드포인트(`v1/uploads/image`)의 응답 규격이 동일하므로 **수정 불필요**. | 영향도 최소화 |
| (UI 컴포넌트) | 이미지를 표시할 때 `f_auto, q_auto` 파라미터가 포함된 URL을 처리하도록 확인. | 마이그레이션된 URL과 동일 적용 |

---

## 3. 세부 작업 단계 (Step-by-Step)

### Step 1: UploadService 리팩토링 (Node.js)
- `uploads.service.ts` 파일에서 `supabase.storage` 대신 `cloudinary` SDK를 import 합니다.
- `uploadToStorage` 함수에서 파일을 Cloudinary로 스트리밍 업로드하도록 리팩토링합니다.
- 이때, 이미지 URL 끝에 `@f_auto,q_auto` 파라미터를 붙여서 반환하거나, Cloudinary의 `transformation` 옵션을 활용합니다.

### Step 2: 응답 데이터 형식 유지
- 기존 `publicUrl` 키값을 유지하여 Flutter Admin 앱에서 에러가 발생하지 않도록 조치합니다.
- 예: `{ publicUrl: "https://res.cloudinary.com/.../f_auto,q_auto/..." }`

### Step 3: 테스트 및 검증
1. 관리자 앱에서 신규 수목 정보 생성 테스트.
2. 생성된 정보의 DB URL이 `res.cloudinary.com`으로 시작하는지 확인.
3. 퀴즈 문항 이미지 업로드 테스트 및 최적화 파라미터 포함 여부 확인.

---

## 4. 일정 및 주의사항
- **예상 소요 시간**: 약 1시간 (코드 수정 및 로컬 테스트 포함)
- **주의사항**:
  - `uploadToStorage` 함수를 수정할 때 기존 Supabase 삭제 로직(`deleteFromStorage`)도 Cloudinary 삭제 로직으로 함께 연동해야 관리자 앱에서 이미지 교체 시 이전 파일이 정상 삭제됩니다.
  - Cloudinary 업로드 시 원본 파일명을 `public_id`에 포함하여 검색 효율성을 높입니다.

---
**작성자**: Antigravity AI Assistant
**작성일**: 2026-04-06 (현지 시각 기준)
