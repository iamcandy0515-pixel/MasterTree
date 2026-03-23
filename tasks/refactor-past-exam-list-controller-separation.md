# [작업 계획서] 'PastExamListController' 모바일 부하 분산 및 기능별 구조 리팩토링

본 계획서는 `DEVELOPMENT_RULES.md`와 `FLUTTER_3_7_12_TECH_SPEC.md`를 엄격히 준수하며, 기출 문제 목록 조회 시 발생하는 네트워크 및 메모리 부하를 방지하고 유지보수성을 극대화하기 위해 작성되었습니다.

## 1. 분석 및 과제 현황
- **현재 파일**: `lib/controllers/past_exam_list_controller.dart` (약 257라인)
- **위반 사항**: 200라인 초과 원칙 위반.
- **주요 부하 요소**:
  - 단일 클래스에서 필터 상태 관리, Supabase 쿼리 빌드, 페이지네이션 제어, 로컬 데이터 저장을 모두 수행함.
  - 문제 문자열 가공(`extractQuestionText`) 로직이 비대하여 비즈니스 로직과 혼재되어 있음.
  - 복잡한 필터 조건에 따른 중복 쿼리 처리 로직이 비효율적임.

## 2. 세부 작업 단계 (Phased Plan)

### Phase 1: 기능 분리 (Modularity & Mixins)
- **대상 위젯/클래스 (`lib/controllers/mixins/` 하위 생성)**:
  - `ExamFilterMixin.dart`: 과목, 연도, 회차 등 필터링 상태 및 완료 로직 격리.
  - `ExamPaginationMixin.dart`: 현재 페이지, 전체 페이지 관리 및 페이지 이동(`first`, `last`, `next`, `prev`) 논리 통합.
  - `ExamPersistenceMixin.dart`: `SharedPreferences`와 연동한 필터 설정 저장/복구 로직 분리.
- **목표**: `PastExamListController.dart` 본체는 이벤트 전달 로직만 담당하도록 경량화.

### Phase 2: 데이터 추상화 및 레이어 분리 (Isolation & Repo)
- **`ExamRepository.dart` 추출**: Supabase 데이터 연동 계층을 완전히 격리하여 컨트롤러의 비대화를 해소.
- **`ExamQueryBuilder.dart` 신규 도입 (더 좋은 제안)**:
  - 필터 조건에 따라 Supabase 요청을 동적으로 구성해주는 전용 헬퍼 클래스 도입 (복잡한 `if` 중첩문 제거).
- **`ExamDataUtility.dart` 추출**: 문제 번호 및 텍스트 파싱 로직을 유틸리티로 격리.

### Phase 3: 모바일 성능 및 리소스 고도화 (Optimization)
- **Infinite Scroll 구조 확보**: 향후 무한 스크롤(Infinite Scroll) 적용이 용이하도록 리스트 병합 및 페이징 로직 설계.
- **메모리 절약**: 대량의 필터 조건 변경 시 불필요한 쿼리 호출을 원천 차단하는 데바운스(Debounce) 고도화.
- **검증**: `flutter analyze` 후 linter 스타일 체크 및 문법 오류 검증.

## 3. Git 커밋 전략 (Commit Strategy)
- **Commit 1**: `docs(exam): add refactoring task plan for past_exam_list_controller following DEVELOPMENT_RULES.md`
- **Commit 2**: `refactor(exam): separate filter, pagination and persistence using Mixins`
- **Commit 3**: `refactor(exam): extract ExamRepository and implement ExamQueryBuilder`
- **Commit 4**: `perf(exam): optimize filter debouncing and prep for infinite scroll`

## 4. 수행 규칙 체크리스트
- [x] 파일당 200라인 이하 준수 여부 (Controller 본체 100라인 이하 목표)
- [x] Mixin 기반 기능 분리 적용
- [x] Flutter 3.7.12 / Dart 2.19.6 호환성 확인
- [x] `linter` 스타일 및 문법 체크 수행

---
**개발자님의 승인 후 작업을 시작하겠습니다.**
