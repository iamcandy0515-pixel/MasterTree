# Task: 설정 화면에 썸네일 구글 드라이브 폴더 설정 추가

## 상태 기록 (Plan)

### 1. 작업 목적

- 관리자 앱의 '설정' 화면에서 수목 이미지 추출 설정에 '썸네일 구글 드라이브 폴더 URL' 입력 필드와 '변경 저장' 버튼을 추가.
- 구글 드라이브 기반의 자동 썸네일 추출 시 참조할 폴더 경로를 시스템 설정으로 관리하기 위함.

### 2. 작업 범위

#### 백엔드 (Node.js API)

- `SettingsService`: `tree_thumbnail_drive_url` 키를 처리하는 `getTreeThumbnailDriveUrl`, `updateTreeThumbnailDriveUrl` 메서드 추가.
- `SettingsController`: 새로운 필드에 대한 조회 및 수정 핸들러 추가.
- `SettingsRoutes`: 새로운 엔드포인트 등록.

#### 프론트엔드 (Flutter Admin App)

- `TreeRepository`: 백엔드의 썸네일 설정 엔드포인트 호출 메서드 추가.
- `SettingsViewModel`: 썸네일 드라이브 URL 상태 관리 및 로딩/수정 로직 추가.
- `SettingsScreen`: 수목 이미지 추출 설정 섹션에 썸네일용 입력 필드와 저장 버튼 UI 추가.

### 3. 기술적 세부 사항

- **DB Key**: `tree_thumbnail_drive_url` (app_settings 테이블)
- **API Endpoint**:
    - GET `/v1/admin/settings/tree-thumbnail-url`
    - POST `/v1/admin/settings/tree-thumbnail-url`

## 실행 (Execute)

### 단계 1: 백엔드 기능 구현

#### 1.1 SettingsService 수정 (tree_thumbnail_drive_url 메서드 추가)

- `src/modules/settings/settings.service.ts`

#### 1.2 SettingsController 수정

- `src/modules/settings/settings.controller.ts`

#### 1.3 SettingsRoutes 수정

- `src/modules/settings/settings.routes.ts`

### 단계 2: 프론트엔드 기능 구현

#### 2.1 TreeRepository 수정

- `lib/features/trees/repositories/tree_repository.dart`

#### 2.2 SettingsViewModel 수정

- `lib/features/dashboard/viewmodels/settings_viewmodel.dart`

#### 2.3 SettingsScreen 수정 (완료)

- `lib/features/dashboard/screens/settings_screen.dart`

## 사후 점검 (Review)

- **완료된 결과 (Result)**:
    - **백엔드**: `app_settings` 테이블에 `tree_thumbnail_drive_url` 키를 사용하는 로직(Service, Controller, Routes)을 추가 완료하였습니다.
    - **프론트엔드 Repository**: `TreeRepository`에 썸네일 URL 조회/수정 API 연동 메서드를 추가하였습니다.
    - **프론트엔드 ViewModel**: `SettingsViewModel`에서 썸네일 설정을 로드하고 업데이트하는 상태 관리 로직을 구현하였습니다.
    - **프론트엔드 UI**: '설정' 화면의 '수목 이미지 추출 설정' 섹션에 썸네일용 입력 필드와 저장 기능을 성공적으로 추가하였습니다.
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - 구글 드라이브 권한(누구나 액세스 가능) 이슈가 발생할 경우 파일 목록이 보이지 않을 수 있으므로, 사용자에게 해당 안내를 강화할 필요가 있습니다.
    - 현재는 설정값만 저장하며, 실제 추출 로직(`google_drive.service.ts`)에서 이 설정값을 활용하도록 로직을 연결하는 후속 작업이 필요할 수 있습니다.
