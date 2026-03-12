# Task: 이미지 로딩 최적화 및 안정화 (Image Loading Optimization & Stabilization) - v1

## 1. 개요 (Overview)
- **목표**: 서버 부하를 줄이고 관리자/사용자 앱의 이미지 로딩 성능을 개선하기 위해 서버 측 리사이징 프록시를 도입함.
- **배경**: 현재 Google Drive 원본 파일을 직접 로딩하거나 프록시 시 원본 그대로 전달하여 메모리 및 네트워크 과부하 발생 가능성 있음.

## 2. 세부 작업 (Detailed Tasks)

### Phase 1: 백엔드 준비 (Backend - Node.js API)
- [x] `sharp` 라이브러리 연동 (설치 완료)
- [x] `uploads.controller.ts`의 `proxyImage` 엔드포인트에 리사이징 쿼리 파라미터 (`w`, `h`) 추가 및 적용 (완료)

### Phase 2: 프론트엔드 연동 (Frontend - Flutter Admin App)
- [x] `tree_repository.dart`: `getProxyUrl` 메서드에 `width`, `height` 선택적 파라미터 추가 (완료)
- [x] `sourcing_image_slot.dart`: 썸네일 노출 시 리사이징 파라미터(예: 300px)를 전달하도록 수정 (완료)
- [x] `flutter analyze` 컴파일 오류 수정 (`quiz_management` ViewModel 불일치 해결) (완료)

### Phase 3: 서비스 안정화 (Service Stabilization)
- [x] `nodejs_admin_api`, `flutter_admin_app`, `flutter_user_app` 재기동 (완료)

### Phase 4: 검증 (Verification)
- [ ] 관리자 앱에서 이미지 로딩 속도 및 서버 로그(리사이징 동작 여부) 확인 (진행 중)

## 3. 진행 상황 (Status)
- [x] Backend: `proxyImage` 리사이징 로직 구현 (완료)
- [x] Frontend: `TreeRepository.getProxyUrl` 파라미터 연동 (완료)
- [x] Frontend: `SourcingImageSlot` 썸네일/원본 최적화 호출 (완료)
- [x] Frontend: `flutter analyze` 컴파일 오류 수정 및 재기동 (완료)
- [ ] Verification: 이미지 로딩 성능 개선 확인 (진행 중)

## 4. 예상 리스크 및 대책 (Risk & Mitigation)
- **CORS 이슈**: 프록시를 유지하므로 안전함.
- **서버 부하**: 실시간 리사이징은 CPU를 소모하지만, 클라이언트 메모리 부족보다는 서버 자원 조절이 용이함. 향후 Redis 캐싱 검토 가능.
