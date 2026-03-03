# Task: 수목 이미지 로딩 문제 해결 및 유사종 비교 화면 고도화

## 1. 목적 (Goal)

- 구글 드라이브 링크 이미지의 로딩 안정성 확보 (CORS 및 리다이렉션 대응)
- 유사종 비교 상세 화면(`SpeciesComparisonDetailScreen`)의 하드코딩된 이미지를 실제 DB 수목 데이터로 교체
- 퀴즈 및 도감 상세 화면의 이미지 로딩 로직 최적화

## 2. 작업 범위 (Scope)

### 2.1. 사용자 앱 (flutter_user_app)

- `SpeciesComparisonDetailScreen.dart`: `picsum.photos` 제거 및 API 연동을 통한 실제 수목 이미지 표시
- `QuizProvider.dart`: 이미지 로딩 실패 시 Fallback 로직 강화
- 이미지 로딩 위젯 공통화 또는 최적화 (구글 드라이브 URL 처리용)

### 2.2. 백엔드 API (nodejs_admin_api)

- 특정 수종의 특정 태그(잎, 수피 등) 이미지를 가져오는 효율적인 API 엔드포인트 확인 또는 추가

## 3. 실행 단계 (Execution Plan)

- [x] **Phase 1: 백엔드 API 확인 및 보완**
    - `UploadController` 및 `UploadRoutes`에 외부 이미지 로딩용 프록시(`GET /proxy`) 추가 (CORS 대응)
- [x] **Phase 2: `SpeciesComparisonDetailScreen` 수정**
    - `tree_groups` API 연동을 통해 실제 DB 데이터 연동 완료
    - 하드코딩된 `picsum.photos` 제거 및 실제 수목 이미지 매칭
- [x] **Phase 3: 이미지 로딩 안정화**
    - `ApiService`에 `getProxyImageUrl` 헬퍼 추가
    - 퀴즈(QuizProvider), 도감(TreeListScreen) 상세 페이지에 프록시 적용 및 로딩 안정화
- [x] **추가 작업**: 테스트용 '아왜나무 vs 황칠나무' 비교 그룹 생성

## 4. 완료된 결과 (Result)

- 구글 드라이브 기반 이미지가 모든 화면에서 정상적으로 로딩됨 (프록시 서버 경유)
- 유사종 비교 목록 및 상세 화면이 실제 DB 데이터와 완전히 동기화됨
- 뒤로가기 아이콘 및 UI 일관성 확보 (`Icons.arrow_back_ios_new`, size: 20)

## 5. 향후 문제점 및 리스크 분석 (Risk Analysis)

- **서버 부하**: 이미지 프록시 서버를 거치므로 백엔드 서버의 트래픽이 증가할 수 있음. (현재 1일 캐싱 적용)
- **데이터 누락**: 특정 수종의 경우 잎/수피 이미지가 DB에 없을 때 placeholder가 표시되나, 데이터 수집을 통한 보완이 필요함.
