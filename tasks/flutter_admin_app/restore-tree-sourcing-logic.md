# 📋 수목소싱 관리 로직 복구 계획서 (restore-tree-sourcing-logic)

## 1. 개요 (Plan)

'수목소싱 관리' 화면의 비어있는 ViewModel 로직을 채우고, 설정된 Google Drive 폴더 정보를 참조하여 수목 이미지를 자동으로 가져오는 기능을 구현합니다. 또한 로컬 이미지 업로드 및 삭제 기능을 활성화하여 수목 데이터 에셋 관리를 완성합니다.

## 2. TODO 리스트

### Phase 1: Backend API 확인 및 보완

- [x] `nodejs_admin_api`: 특정 수목명으로 모든 카테고리(5종) 이미지를 일괄 검색하는 API 확인 및 추가.
- [x] 이미지 업로드 처리용 멀티파트 요청 대응 확인.

### Phase 2: Repository (Data Layer)

- [x] `TreeRepository.searchDriveImages(treeName)`: 구글 드라이브 검색 요청 구현.
- [x] `TreeRepository.updateTreeImages(treeId, images)`: 최종 변경사항 저장 로직.
- [x] `TreeRepository.uploadImage(fileBytes, filename)`: 멀티파트 업로드 구현.

### Phase 3: ViewModel (Business Logic)

- [x] `loadTrees()`: 전체 수목 데이터 로드.
- [x] `fetchFromDrive()`: 선택된 수목의 이름을 기반으로 백엔드에 드라이브 이미지 검색 요청.
- [x] `pickImage(type)`: `image_picker` 연동.
- [x] `removeImage(id)`: UI 상 삭제 및 삭제 대기 상태 관리.
- [x] `saveChanges()`: 변경된 이미지 정보를 서버에 반영.

### Phase 4: UI (Presentation Layer)

- [x] `ImageManagementSection`: 드라이브 동기화 버튼 및 로딩 UI 추가.
- [x] 이미지 썸네일 렌더러: 로컬 파일(XFile)과 네트워크 URL 구분 처리.

## 3. 실행 (Execute)

- 로직 구현 및 단계별 테스트 진행.

## 4. 사후 점검 및 리스크 분석 (Review & Risk Analysis)

- **Result**: 수목별 이미지가 구글 드라이브와 연동되어 효율적인 소싱 시스템 구축.
- **Risk Analysis**:
    - Google Drive API 속도에 따른 UI 지연 가능성 -> 캐싱 또는 백그라운드 로딩 고려.
    - 파일명 규칙({나무명}\_{부위}) 불일치 시 검색 실패 대응 필요.
