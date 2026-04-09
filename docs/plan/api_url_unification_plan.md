# [작업계획서] API 통신 주소 환경 변수 통합 (API_URL/NODE_API_URL -> APP_BASE_URL)

## 1. 개요
현재 프로젝트 전반에서 Node 서버의 API 주소를 지칭하는 환경 변수가 `API_URL`(사용자 앱)과 `NODE_API_URL`(관리자 앱)로 혼재되어 사용되고 있습니다. 이를 `APP_BASE_URL`로 통합하여 유지보수 효율성을 높이고 Vercel 환경 설정의 중복을 제거합니다.

## 2. 준수 사항
- **변수명 통일**: 모든 클라이언트 앱(Flutter) 및 서버 설정 파일에서 API 주소 변수명을 `APP_BASE_URL`로 변경합니다.
- **하드코딩 제거**: `flutter_admin_app`의 `node_api.dart` 등에 포함된 하드코딩된 서버 주소를 제거하거나 환경 변수 우선 순위로 조정합니다.
- **정합성 체크**: 수정 후 `flutter_user_app` 및 `flutter_admin_app`의 빌드 및 통신 상태를 확인합니다.

## 3. 소스 수정 일람 (Modification List)

| No | 파일 경로 | 기존 변수 | 변경 후 변수 / 조치 내용 |
| :--- | :--- | :--- | :--- |
| **0** | `.env.master` | `API_URL`, `NODE_API_URL` | `APP_BASE_URL`로 통합 |
| **1** | `flutter_user_app/assets/env_config` | `API_URL` | `APP_BASE_URL`로 이름 변경 |
| **2** | `flutter_user_app/lib/core/constants.dart` | `API_URL` 참조 | `APP_BASE_URL` 참조하도록 수정 |
| **3** | `flutter_admin_app/assets/env_config` | `API_URL`, `NODE_API_URL` | `APP_BASE_URL`로 통합 및 단일화 |
| **4** | `flutter_admin_app/lib/core/api/node_api.dart` | `NODE_API_URL` 참조 | `APP_BASE_URL` 참조 및 하드코딩 주소 업데이트 |
| **5** | `nodejs_admin_api/public/user/assets/assets/env_config` | `API_URL` | `APP_BASE_URL`로 이름 변경 (배포용 자산) |
| **6** | `nodejs_admin_api/public/admin/assets/assets/env_config` | `API_URL`, `NODE_API_URL` | `APP_BASE_URL`로 통합 (배포용 자산) |

## 4. 상세 작업 To-Do List

- [ ] **T1. 마스터 설정 및 자산 파일 수정**
  - [ ] `.env.master` 파일 내 변수명 수정
  - [ ] 각 Flutter 프로젝트(`user`, `admin`)의 `assets/env_config` 파일 수정
- [ ] **T2. Flutter 소스 코드 코드 수정**
  - [ ] `flutter_user_app` 내 `constants.dart` 수정
  - [ ] `flutter_admin_app` 내 `node_api.dart` 수정 (하드코딩된 구버전 주소 제거 포함)
- [ ] **T3. 서버 내 배포용 정적 자산 수정**
  - [ ] `nodejs_admin_api/public/` 하위의 `env_config` 파일들 동기화 수정
- [ ] **T4. 최종 검증**
  - [ ] 각 앱 빌드 후 API 통신 정상 여부 확인
  - [ ] Vercel 및 로컬 환경 변수 설정값 일치 확인

---
> [!IMPORTANT]
> **개발자 승인 후 구현 시작**: 본 계획서 승인 후에 실제 코드 일괄 치환 및 수정을 진행하겠습니다.
