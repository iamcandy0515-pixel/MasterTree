# To-Do List: 수목 이미지 및 썸네일 전면 복구

## Phase 1: 백엔드(Node.js API) 복구
- [ ] `trees.dto.ts`에 `thumbnail_url` 필드 추가
- [ ] `trees.service.ts`의 CRUD 로직에 `thumbnail_url` 필드 반영
- [ ] `UploadController.proxyImage`에 OAuth2 인증 연동 로직 추가
- [ ] `external.controller.ts`에 `generateThumbnail` 및 `getDriveLinks` API 구현
- [ ] `external.routes.ts`에 신규 라우트 등록

## Phase 2: 프론트엔드 ViewModel 분리 (Rule 1-1 준수)
- [ ] `TreeSourcingViewModel` 분석 및 분리 설계 (List / Detail / Drive)
- [ ] `TreeSourcingViewModel` 분할 및 기존 코드 리팩토링 (파일당 200줄 이내)

## Phase 3: 기능 연동 및 UI 강화
- [ ] `TreeRepository` 업데이트 (썸네일 URL 매핑 및 신규 API 메서드)
- [ ] `initDetail`에서 파일 실재 여부 체크 로직 강화
- [ ] `SourcingImageSlot`에 `_fileMissing` 경고 UI 추가
- [ ] 동일 URL 저장 시도 시 SnackBar 메시지 출력

## Phase 4: 최종 검증
- [ ] `flutter analyze` 린트 체크
- [ ] 빌드 및 런타임 테스트
- [ ] 최종 Git Commit 및 작업 종료
