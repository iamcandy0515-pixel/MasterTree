# [고도화 계획서] 구글 드라이브 ID 자동 추출 및 전역 참조 시스템 구축

## 1. 개요
사용자가 '설정' 화면에서 입력한 구글 드라이브 URL로부터 복잡한 폴더 ID를 자동으로 추출하고, 이를 백엔드의 검색 및 파싱 로직에 실시간으로 반영합니다. 또한, 관리자 앱의 각 기능(문제 추출, 이미지 소싱) 진입 시 설정된 폴더가 기본으로 세팅되도록 전역 참조 시스템을 고도화합니다.

---

## 2. 주요 작업 내용 (Core Tasks)

### Phase 1: 드라이브 ID 추출 로직 강화 (Backend)
- [ ] **정규식 기반 유틸리티 도입**:
    - `nodejs_admin_api/src/utils/drive-helper.ts` (신규) 생성.
    - `folders/ID`, `id=ID`, `open?id=ID` 등 다양한 드라이브 URL 형식을 완벽하게 지원하는 Regex 구현.
- [ ] **GoogleDriveService 리팩토링**:
    - `google_drive.service.ts`에서 하드코딩된 `GOOGLE_DRIVE_FOLDER_ID`를 제거.
    - 모든 메서드가 `folderId`를 명시적으로 인자로 받거나, `settingsService`로부터 동적으로 로드하도록 수정.
- [ ] **Controller 연동**:
    - `external.controller.ts`에서 수동으로 ID를 추출하던 로직을 신규 유틸리티로 교체하여 안정성 확보.

### Phase 2: 전역 폴더 참조 시스템 연결 (Frontend & Backend)
- [ ] **이미지 소싱 자동화 (Image Sourcing)**:
    - 수목 상세 화면의 '이미지 소싱' API 호출 시, 백엔드에서 `settingsService`의 `google_drive_folder_url`을 자동으로 참조하여 검색 범위를 한정.
- [ ] **기출문제 추출 자동화 (Quiz Extraction)**:
    - `flutter_admin_app`의 기출문제 추출 화면 진입 시, `SettingsViewModel`의 폴더 정보를 초기값으로 주입하여 사용자 입력 최소화.
- [ ] **배치 작업 동적 타겟팅**:
    - 서버 사이드 썸네일 생성 시 `thumbnail_drive_url`을 실시간으로 가져와 대상 폴더로 사용.

### Phase 3: 예외 처리 및 UX 개선
- [ ] **URL 유효성 실시간 검증**: 설정 저장 시점에 ID 추출이 불가능한 URL일 경우 즉각 에러 반환.
- [ ] **폴더 권한 사전 검사**: 추출된 ID를 기반으로 드라이브 API `files.get`을 호출하여 '접근 권한(403)' 여부를 미리 확인하는 기능 추가.

---

## 3. 관련 작업 파일 (File Mapping)

### Backend (Node.js)
1. `src/utils/drive-helper.ts`: ID 추출 정규식 유틸리티
2. `src/modules/external/google_drive.service.ts`: 동적 ID 주입 로직
3. `src/modules/external/external.controller.ts`: 설정값 참조 및 유효성 검사
4. `src/modules/settings/settings.service.ts`: 설정값 제공 API

### Frontend (Flutter)
1. `lib/features/trees/viewmodels/tree_sourcing_viewmodel.dart`: 기본 폴더 정보 연동
2. `lib/features/dashboard/viewmodels/settings_viewmodel.dart`: 설정값 전역 관리 및 배포
3. `lib/features/quiz/screens/quiz_extraction_screen.dart`: 폴더 URL 자동 주입

---

## 4. 기대 효과
- **운영 효율**: 폴더 ID를 수동으로 찾아 입력할 필요 없이 URL만 붙여넣으면 즉시 앱의 모든 기능이 연동됨.
- **데이터 일관성**: 설정 한 번으로 문제 추출 및 이미지 검색 경로가 통일되어 관리 실수 방지.
- **보안/안정성**: 잘못된 URL 입력에 대한 사전 차단 및 명확한 에러 메시지 제공.
