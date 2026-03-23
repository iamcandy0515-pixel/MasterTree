# 🧩 작업계획서: API 서비스(ApiService) 기능 분리 및 아키텍처 개선

## 1. 개요 (Overview)
- **작업명**: `lib/core/api_service.dart` 도메인별 분리 및 공통 통신 레이어(Base API Client) 구축
- **배경**: 현재 `api_service.dart`가 약 365라인으로, 운영 규칙인 **[1-1. 200줄 제한 원칙]**을 초과함. 중복되는 HTTP 요청 핸들링을 제거하고, 도메인별(Tree, Quiz, Stats, Sync) 독립성을 확보하여 코드 품질을 상향 평준화함.
- **담당**: Antigravity (AI Coding Assistant)

## 2. 작업 전제 조건 (Pre-requisites)
- [ ] **[0-1. Git 백업]** 전체 작업 시작 전, 현재 상태를 `git commit` 확인.
- [ ] **[0-2. 환경 설정]** 터미널 인코딩 `chcp 65001` 적용 확인.
- [ ] **[4-1. 버전 준수]** Flutter `3.7.12`, Dart `2.19.6` 환경 유지 및 검증.

## 3. 리팩토링 및 아키텍처 전략 (Refactoring Strategy)
- **Base Client 도입**: `lib/core/api/base_api_service.dart`를 생성하여 공통 헤더(Auth), UTF-8 디코딩, 에러 처리 로직을 중앙화.
- **도메인 서비스 분해**:
    - `TreeService`: 수목 검색 및 목록 페칭 로직.
    - `QuizService`: 퀴즈 생성 및 세션/결과 제출 로직.
    - `StatsService`: 사용자 학습 통계 연동 로직.
    - `SyncService`: 로컬 캐시(SharedPreferences) 기반 학습 데이터 동기화 관리 로직.
- **데이터 정합성**: **[1-2. 효율적 통신]** 원칙에 따라 싱글톤 또는 팩토리 패턴을 활용하여 리소스를 효율적으로 관리.

## 4. To-Do List
### Phase 1: 공통 통신 레이어(Base) 구축
- [x] `lib/core/api/base_api_service.dart` 생성 (Auth Header, HTTP Wrapper 메서드)
- [x] `lib/core/api/api_constants.dart` 엔드포인트 상수 정의 (기존 Constants 활용)

### Phase 2: 도메인 서비스 추출 및 구현
- [x] `lib/core/api/tree_service.dart` 추출 (Tree 목록, 이미지 프록시)
- [x] `lib/core/api/quiz_service.dart` 추출 (퀴즈 세션, 배치 제출)
- [x] `lib/core/api/stats_service.dart` 추출 (사용자 대시보드 및 퍼포먼스 통계, 그룹 포함)
- [x] `lib/core/api/sync_service.dart` 추출 (로컬 캐시 및 보류 중인 결과 동기화)

### Phase 3: 전역 참조 업데이트 및 최적화
- [x] 기존 `ApiService` 호출부(Providers, Controllers) 유지를 위한 Proxy/Facade 구성
- [x] `api_service.dart` 파일 경량화 (365라인 -> 70라인)
- [x] **[3-2. 린트 체크]** `flutter analyze` 명령어로 스타일 및 문법 오류 제로(0) 확인
- [x] **[0-4. 소스 정합성]** `diff` 분석을 통해 의도치 않은 로직 삭제 여부 최종 확인

## 5. 기대 효과 (Expected Outcomes)
- 신규 서비스 파일들이 각각 **100라인 이내**로 경량화됨.
- API 통신 로직이 중앙화(`BaseApiService`)되어 에러 핸들링 및 토큰 관리가 일관되게 적용됨.
- 코드 재사용성 및 유닛 테스트(Unit Test) 작성의 용이성 확보.

---
**주의**: 본 계획서는 개발자의 최종 승인 후 구현을 시작합니다.
