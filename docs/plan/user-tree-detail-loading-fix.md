# [작업 계획서] 사용자 앱 수목 상세 정보 로딩 개선 (방식 A)

**문서 경로**: `d:\MasterTreeApp\tree_app_monorepo\docs\plan\user-tree-detail-loading-fix.md`
**작성일**: 2026-04-01

## 1. 전제 조건 및 준비
- [ ] **[0-1. Git 백업]** 전체 소급 작업 전 로컬 커밋 수행.
- [ ] **[0-2. 환경 최적화]** 터미널 인코딩(`chcp 65001`) 점검.

## 2. 주요 작업 내역
- [ ] **API 서비스 모듈화**: `TreeService`에 `/api/trees/:id` 연동 상세 조회 메서드 추가.
- [ ] **상세 시트 로드 로직 변경**: `TreeDetailSheet` 초기화 시 서버에서 전체 정보를 직접 Fetch.
- [ ] **[1-1. 소스 스플리팅]**: `TreeDetailSheet`가 200줄을 넘지 않도록 서브 위젯(`TreeHintCard`, `TreeStatsList`)을 별도 분리.
- [ ] **데이터 정제 최적화**: `TreeListController.processImageData`를 활용하여 일관된 데이터 매핑 보장.

## 3. 검증 및 마무리
- [ ] **[3-2. 린트 체크]** `flutter analyze`를 통한 잠재적 이슈 해결.
- [ ] **[0-4. 정합성 체크]** Diff 분석 및 최종 커밋.
