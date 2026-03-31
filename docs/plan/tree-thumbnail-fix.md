# 🌳 수목 썸네일 출력 및 로직 개선 작업계획서 (DEVELOPMENT_RULES.md 준수)

## 1. 개요
관리자앱의 '수목 이미지 추출 상세' 화면에서 썸네일 이미지가 출력되지 않는 문제를 해결하고, DB 정보와 구글 드라이브 실물 상태를 대조하여 시각화하는 기능을 구현합니다. 이 작업은 `DEVELOPMENT_RULES.md`의 2-1 규정에 따라 작업 계획 및 To-Do List를 포함합니다.

## 2. 상세 요구사항 분석 및 해결 전략

### [요구사항 1-1, 1-2, 1-3: 데이터 연동 및 출력]
- **분석**: 화면 진입 시 DB의 `image_url`, `thumbnail_url` 정보와 구글 드라이브 폴더의 파일 목록을 병합해야 함.
- **전략**: 
  - `TreeSourcingViewModel.syncWithDrive`에서 백엔드 API로부터 `original` 및 `thumb` 폴더의 최신 링크를 가져옴.
  - 썸네일 출력 시 `NodeApi.getProxyImageUrl`에 `width=300` 옵션을 명시하여 성능 최적화.

### [요구사항 1-4: 실물 부재 시 "없다는 표시"]
- **분석**: DB에는 URL이 있지만 구글 드라이브에서 삭제되었을 경우 경고 표시 필요.
- **전략**: 
  - `isMissing` 상태일 때 이미지 슬롯을 숨기는 대신, **빨간색 테두리(`Colors.redAccent`)**와 **우측 상단 경고 아이콘**을 중첩 표시하여 시각화.

### [요구사항 1-5: "DB 정보" 배지 출력]
- **분석**: 데이터 출처가 DB인 경우 사용자가 명확히 인지해야 함.
- **전략**: 
  - `SourcingImageSlot`의 배지 로직에서 데이터가 DB 기반일 경우 파란색 배경의 **'DB 정보'** 텍스트 출력 고정.

## 3. To-Do List (작업 체크리스트)

### Phase 1: ViewModel (Data Layer) 개선
- [ ] `tree_sourcing_viewmodel_drive.part.dart` 수정
    - [ ] `manual` 동기화가 아닐 때도 구글 드라이브에서 발견된 새로운 링크를 `source: 'google'`로 명확히 구분.
    - [ ] DB 정보와 구글 정보를 비교하여 갱신 로직 정밀화.
- [ ] `_checkExistence` 메서드에서 썸네일 URL 체크 강화.

### Phase 2: UI (Presentation Layer) 위젯 개선
- [ ] `sourcing_image_slot.dart` 수정
    - [ ] `displayItem` 결정 로직에서 `isMissing` 시 `null` 반환 제거 (이미지 시도는 하되 경고 표시).
    - [ ] `Stack` 레이아웃 내 빨간색 테두리 조건부 스타일 적용 (Requirement 1-4).
    - [ ] `_buildSourceBadge` 내 'DB 정보' 노출 조건 및 스타일 고정 (Requirement 1-5).
    - [ ] 썸네일 슬롯(`isThumb: true`)인 경우 `proxyImageUrl`의 `width: 300` 고정 적용 확인.

### Phase 3: 검증 및 품질 관리
- [ ] `flutter analyze` 실행하여 린트 에러 0건 확인.
- [ ] 실제 화면에서 'DB 정보' 배지 및 경고 표시 레이아웃 확인.
- [ ] 썸네일 이미지 로딩 속도 및 프록시 응답 확인.

---
**작성일**: 2026-04-01  
**담당**: Antigravity (AI Coding Assistant)
