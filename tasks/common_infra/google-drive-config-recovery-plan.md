# [복구 계획서] 관리자 앱 3대 구글 드라이브 폴더 통합 관리 시스템

## 1. 개요
관리자 앱의 '설정' 메뉴에서 서비스 운영에 핵심적인 3가지 구글 드라이브 폴더(기출문제 PDF, 수목 원본 이미지, 썸네일 이미지)의 URL을 통합적으로 관리하고, 이를 각 기능(문제 추출, 이미지 소싱, 배치 작업)에서 실시간으로 참조할 수 있도록 동기화합니다.

---

## 2. 통합 관리 대상 (3대 폴더)
1. **기출문제 폴더 (Exam PDF)**: 
    - 용도: `QuizService`에서 PDF 내 문제 및 해설을 AI로 추출할 때 원본 소스로 사용.
    - DB Key: `google_drive_folder_url` (기존 키 재사용)
2. **수목 이미지 폴더 (Tree Origin)**: 
    - 용도: 수목 상세 정보의 '이미지 소싱' 화면에서 구글 드라이브 내 원본 수목 사진을 검색/연동할 때 사용.
    - DB Key: `google_drive_folder_url` (기존 키와 통합 또는 용도별 분리 확인 필요)
3. **썸네일 이미지 폴더 (Thumbnail)**: 
    - 용도: 서버 사이드 배치 작업(`ThumbnailService`)에서 생성된 저용량 이미지를 업로드하고 관리할 때 사용.
    - DB Key: `thumbnail_drive_url`

---

## 3. 상세 작업 계획 (Execute)

### Phase 1: 백엔드(Node.js API) 기반 구축
- [x] **`app_settings` 테이블 규격 확인**: `key`, `value` 기반의 설적 정보 저장 구조 확인.
- [x] **`settings.service.ts` 확장**:
    - `getGoogleDriveFolderUrl` / `updateGoogleDriveFolderUrl` (기출/이미지 공용)
    - `getThumbnailDriveUrl` / `updateThumbnailDriveUrl` (썸네일 전용)
- [ ] **드라이브 ID 추출 로직 고도화**: URL에서 `folder_id`를 정규식으로 안전하게 추출하는 공통 유틸리티 적용.

### Phase 2: 관리자 앱(Flutter Admin App) UI/UX 연동
- [x] **`settings_screen.dart` 레이아웃 구성**:
    - '수목 이미지 설정' 섹션 내에 원본 폴더 및 썸네일 폴더 입력 필드 배치.
    - 개별 '변경 저장' 버튼 및 로딩 인디케이터 적용.
- [x] **`SettingsViewModel` 연동**: `loadSettings` 호출 시 3개 폴더 정보를 동시 로드하도록 `Future.wait` 적용.
- [x] **`TreeRepository` API 연결**: 서버의 설정 엔드포인트(`GET/POST /api/settings/...`)와 연동하는 통신부 구현.

### Phase 3: 기능별 실시간 참조 (Sync)
- [ ] **문제 추출 화면**: `extractQuizBatchFromPdf` 호출 시 설정된 드라이브 URL을 기본 경로로 제안.
- [ ] **이미지 소싱(Sourcing) 화면**: `external/google-images` API 호출 시 설정에 등록된 폴더 ID를 우선 검색 범위로 지정.
- [ ] **배치 작업**: 서버 사이드 썸네일 생성 시 설정된 `thumbnail_drive_url`에 자동 업로드 수행.

---

## 4. 관련 작업 파일 (File Mapping)
- **Settings Screen**: `flutter_admin_app/lib/features/dashboard/screens/settings_screen.dart`
- **Settings VM**: `flutter_admin_app/lib/features/dashboard/viewmodels/settings_viewmodel.dart`
- **Settings Backend**: 
    - `nodejs_admin_api/src/modules/settings/settings.service.ts`
    - `nodejs_admin_api/src/modules/settings/settings.controller.ts`
- **Drive Logic**: `nodejs_admin_api/src/modules/external/google_drive.service.ts`

---

## 5. 검증 및 사후 관리
- **URL 유효성 체크**: 잘못된 형식의 URL 입력 시 프론트엔드에서 즉각적인 경고 출력.
- **권한 체크**: 설정된 폴더 ID에 대해 서비스 계정의 '읽기/쓰기' 권한이 있는지 확인하는 API 트리거 버튼 추가 고려.
- **동기화 확인**: 설정 변경 후 수목 이미지 소싱 시 변경된 폴더에서 검색되는지 실시간 테스트.
