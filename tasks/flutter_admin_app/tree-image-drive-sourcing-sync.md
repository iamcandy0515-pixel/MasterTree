---
description: 구글 드라이브 원본/썸네일 폴더 연동 및 서버 사이드 썸네일 생성 기능 구현 (배치 작업 패턴 적용)
---

# 🌳 [Task] 수목 이미지 및 썸네일 통합 관리 구현 (Sync & Generate)

본 작업은 관리자 앱에서 수목의 원본 이미지를 기반으로 썸네일을 생성하거나, 구글 드라이브 내 기존 썸네일을 DB와 동기화하는 시스템을 구축합니다. 특히 기존 배치 작업(`batch_generate_thumbnails.ts`)의 검증된 로직을 참조합니다.

## 📅 단계별 계획

### Phase 0: 특정 수종(신갈나무) 썸네일 동기화 배치 스크립트

- [x] **`sync_shingal_thumbnails.ts` 생성**:
    - '설정'에 등록된 **구글 드라이브 썸네일 폴더 ID**를 실시간으로 가져와 참조.
    - '신갈나무'의 각 카테고리(대표, 수피, 잎, 꽃, 열매) 명칭이 포함된 파일 검색.
    - 검색된 드라이브 파일의 `id`를 기반으로 `view` URL을 생성하여 DB의 `thumbnail_url` 필드를 즉시 업데이트.
    - 실행 명령어: `npx ts-node scripts/sync_shingal_thumbnails.ts`

### Phase 1: 백엔드(Node.js API) 기능 고도화

- [ ] **실시간 썸네일 생성 서비스 (`ThumbnailService`)**:
    - 배치 작업 로직을 API화하여 `sharp`를 이용한 300x300 WebP 리사이징 수행.
    - 생성된 결과물을 구글 드라이브의 '썸네일 폴더'에 업로드하고 DB 연동.
- [ ] **API 엔드포인트**:
    - `POST /v1/service/external/google-images/generate-thumbnail`: 특정 이미지를 대상으로 서버 사이드 썸네일 생성 공정 수행.

### Phase 2: 플러터 앱(Admin App) 연동 및 UI 개선

- [ ] **레포지토리 업데이트 (`tree_repository.dart`)**:
    - 서버의 신규 썸네일 생성 API를 호출하는 `syncThumbnailToServer` 메서드 추가.
- [ ] **뷰모델 수정 (`tree_sourcing_viewmodel.dart`)**:
    - `generateThumbnailForCategory` 로직을 기존 '클라이언트 로컬 생성'에서 '서버 배치 패턴 호출'로 교체.
    - 서버에서 반환된 URL을 `pendingImages`와 화면 이미지 박스에 즉각 반영.

### Phase 3: UI/UX 고도화 (`tree_sourcing_detail_screen.dart`)

- [ ] 화면 진입 시 DB 데이터와 설정된 드라이브 경로의 원본/썸네일 존재 여부 매칭 확인.
- [ ] 작업 결과로 반환된 구글 드라이브 URL을 URL 입력 필드와 이미지 박스에 즉각 반영.

## ⚠️ 리스크 분석 (Risk Analysis)

- **API 타임아웃**: 드라이브 다운로드/리사이징/업로드가 포함된 연쇄 작업이므로 API 타임아웃 설정을 넉넉히 조정해야 함.
- **이미지 명칭 규칙**: 배치 작업과 동일하게 `${tree_name}_${category}_thumb.webp` 규칙을 유지하여 검색 효율성 확보.
- **권한 관리**: 드라이브 서비스 계정이 설정된 썸네일 폴더에 대한 '편집자' 권한을 가지고 있어야 함.
