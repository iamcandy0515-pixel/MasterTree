# 🚀 이미지 로딩 최적화 작업 계획서 (Image Loading Optimization)

## 1. 개요 (Overview)
- **목적**: 관리자 앱의 이미지 추출 상세 화면에서 원본 이미지를 그대로 로드함에 따라 발생하는 서버 부하 및 클라이언트 메모리 점유 문제를 해결하기 위함.
- **전략**: 백엔드 프록시 서버에서 `sharp` 라이브러리를 활용한 실시간 리사이징(On-the-fly resizing) 기능을 구현하고, 프론트엔드에서 썸네일 노출 시 최적화된 크기만 요청하도록 수정함.

## 2. 작업 범위 (Scope)

### [Backend] nodejs_admin_api
- [ ] `uploads.controller.ts`의 `proxyImage` 메서드 수정: `width` 쿼리 파라미터 처리 로직 추가.
- [ ] `sharp` 라이브러리를 이용해 이미지 스트림 리사이징 파이프라인 구축.

### [Frontend] flutter_admin_app
- [ ] `TreeRepository.getProxyUrl` 메서드 확장: `width` 인자를 선택적으로 받을 수 있도록 수정.
- [ ] `SourcingImageSlot` 위젯 수정: `isThumb`가 `true`일 경우 `width=200` 옵션을 적용하여 호출.
- [ ] `memCacheWidth` 설정을 요청 크기에 맞게 최적화.

## 3. To-Do List

### Phase 1: 준비 및 백업 (Preparation)
- [ ] 현재 작업 상태 로컬 Git 커밋 (`Pre-optimization backup`)

### Phase 2: 백엔드 기능 구현 (Backend Implementation)
- [ ] `nodejs_admin_api`에 `sharp` 설치 여부 확인 및 필요시 설치.
- [ ] `uploads.controller.ts` 수정 및 테스트.

### Phase 3: 프론트엔드 적용 (Frontend Implementation)
- [ ] `tree_repository.dart` 수정.
- [ ] `sourcing_image_slot.dart` 수정.

### Phase 4: 검증 (Verification)
- [ ] `flutter analyze` 명령어로 린트 에러 체크.
- [ ] 관리자 앱에서 이미지 로딩 속도 및 서버 로그(리사이징 동작 여부) 확인.

## 4. 예상 리스크 및 대책 (Risk & Mitigation)
- **CORS 이슈**: 프록시를 유지하므로 안전함.
- **서버 CPU 부하**: 실시간 리사이징은 CPU를 소모함. 향후 부하가 커질 경우 캐싱 레이어(Redis 또는 Storage) 도입 고려.
- **이미지 품질**: `sharp` 설정 시 적절한 quality(기본 80)를 유지함.

---
**진행 가이드**: 각 단계를 완료할 때마다 체크박스를 업데이트하며 진행합니다.
