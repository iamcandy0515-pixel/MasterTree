# [작업 계획서] 'QuizController' 기능 분리 및 중복 제거 리팩토링

본 계획서는 `DEVELOPMENT_RULES.md`를 준수하며, 특히 `QuizController`와 `QuizViewModel` 간의 코드 중복을 해결하고 모바일 성능을 최적화하기 위해 작성되었습니다.

## 1. 분석 및 과제 현황
- **현재 파일**: `lib/controllers/quiz_controller.dart` (272라인)
- **핵심 문제**: 
  - `QuizViewModel`과 거의 로직이 동일하여 중복 코드가 발생함.
  - API 호출, 타이머 관리, 상태 추적 등이 한 곳에 집중되어 있음.
  - `precacheImage` 부재로 인해 문제 전환 시 이미지 로딩 체감이 큼.

## 2. 세부 작업 단계 (Phased Plan)

### Phase 1: 공통 기능 Mixin 추출 (Shared Modularity)
- **대상 (`lib/controllers/mixins/` 하위)**:
  - `QuizTimerMixin.dart`: 타이머(힌트, 설명) 제어 로직 추출.
  - `QuizStateMixin.dart`: 퀴즈 진행 상태(인덱스, 점수 등) 변수 추출.
- **효과**: `QuizController`와 `QuizViewModel` 모두에서 재사용 가능하게 구성.

### Phase 2: 데이터 추상화 및 레이어 분리 (Data Isolation)
- **`QuizRepository.dart` 추출**: `ApiService` 호출 및 시도 결과 저장을 담당.
- **`QuizDataMapper.dart` 추출**: 복잡한 `Map` 데이터를 `QuizQuestion` 모델로 변환하는 순수 함수 격리.
- **목표**: `QuizController` 본체 코드를 **80라인 이하**로 축소.

### Phase 3: 성능 및 UX 고도화 (Optimization)
- **Proactive Image Pre-fetching**: 퀴즈 시작 및 진행 시 다음 문제 이미지를 미리 로컬에 캐싱.
- **Stateless 관점 유지**: `QuizController` 내 불필요한 필드 제거 및 기능 중심의 인터페이스 제공.

## 3. 더 좋은 제안 (Superior Proposal)
1. **코드 공유 아키텍처 (Shared Architecture)**: 추출된 Mixin과 Repository를 `QuizViewModel`에도 적용하여 프로젝트 전체의 퀴즈 로직 일관성을 확보하고 전체 코드량을 150라인 이상 절감할 것을 제안합니다.
2. **Batch Processing Optimizer**: 100개 상당의 데이터를 매핑할 때 메인 스레드 부하를 줄이기 위해 루프 최적화를 적용합니다.
3. **Reactive State Pattern**: 단순 `VoidCallback` 대신 `ValueNotifier` 등을 활용하여 리렌더링 범위를 더욱 좁히는 방식을 제안합니다.

## 4. Git 커밋 전략 (Commit Strategy)
- **Commit 1**: `docs(quiz): add unified refactoring task plan for QuizController and shared logic`
- **Commit 2**: `refactor(quiz): extract shared Mixins and Repository for quiz logic`
- **Commit 3**: `refactor(quiz): clean up QuizController using shared components`
- **Commit 4**: `perf(quiz): implement pre-fetching and data mapping optimization`

---
**개발자님의 승인 후 작업을 시작하겠습니다.**
