# Task: QuizExtractionStep2ViewModel 소스 분리 및 비즈니스 로직 모듈화

`lib/features/quiz_management/viewmodels/quiz_extraction_step2_viewmodel.dart` (510라인)의 비대해진 로직을 기능별 Mixin과 Service 레이어로 분리하여 **[1-1. 200줄 소스 코드 제한]** 원칙을 준수하고 유지보수 효율을 높입니다.

## 1. 목적 및 배경 (Objective & Context)
- **책임 과부화**: 단일 뷰모델이 구글 드라이브 파일 탐색, AI 기반 퀴즈/오답/해설/힌트 생성, DB 저장, 이미지 업로드 등 모든 도메인 로직을 직접 처리하고 있음. (규칙 1-1 초과)
- **상태 관리 복잡도**: 10여 개의 독립적인 `bool` 로딩 상태값이 혼재되어 상태 변화 추적이 어렵고 빌드 부하가 발생할 가능성이 있음.
- **코드 중복 및 테스트 어려움**: 비즈니스 로직이 뷰모델 내부에 강하게 결합되어 있어, 다른 단계(Step 1, Step 3)에서 유사 로직 재사용이 불가능함.

## 2. 세부 구현 전략 (Implementation Strategy)
### A. Mixin을 활용한 기능적 분할 (Functional Decomposition)
- **`QuizFileHandlerMixin`**: 구글 드라이브 파일 검색(`searchFiles`), 검증(`validateFile`), 추출(`extractQuiz`) 로직 및 관련 상태를 분리.
- **`QuizAiAssistantMixin`**: AI 연동 추천(`recommendRelated`), 오답 생성(`generateDistractors`), 힌트 생성(`generateHints`), 해설 리뷰 로직 이관.
- **`QuizImageHandlerMixin`**: 퀴즈 이미지 업로드(`uploadQuizImage`), 퀴즈 데이터 내 이미지 추가/삭제 로직 담당.

### B. 상태 관리 최적화 (State Optimization)
- **UI 상태 단일화**: 산발적인 `_isLoading`, `_isSearching`, `_isSaving` 등을 통합하여 `notifyListeners()` 호출 시점과 범위를 정교하게 제어.
- **메인 뷰모델 슬림화**: `QuizExtractionStep2ViewModel`은 조립된 Mixin들의 오케스트레이션과 UI 인터페이스 역할만 수행하도록 **180라인 이내**로 축소.

### C. 규칙 준수 (Rule Compliance)
- **200줄 제한**: 모든 분리된 파일(`Part` 파일 포함)이 200라인을 넘지 않도록 철저히 감독.
- **린트 정합성**: `prefer_final_fields`, `const_constructors` 등 린트 규칙을 100% 만족하도록 수정.

## 3. 작업 일정 및 단계 (Execution Phases)
### Phase 1: Mixin 기반 기능 추출 (lib/features/quiz_management/viewmodels/parts/)
- [ ] `quiz_file_handler_mixin.dart` 생성 및 파일 제어 로직 이관.
- [ ] `quiz_ai_assistant_mixin.dart` 생성 및 AI 연계 비즈니스 로직 이관.
- [ ] `quiz_image_handler_mixin.dart` 생성 및 미디어 처리 로직 이관.

### Phase 2: 메인 뷰모델 재구조화
- [ ] `QuizExtractionStep2ViewModel`에서 기존 로직 제거 후 Mixin들과 결합(`with` 키워드).
- [ ] 메인 파일 내의 `Provider` 데이터 매핑 및 최종 DB 저장(`saveToDb`) 로직 정합성 확인.
- [ ] 뷰모델 파일 라인 수 최종 점검 (150~180라인 타겟).

### Phase 3: 최종 검증 및 동기화
- [ ] **[3-2. 린트 체크]** `flutter analyze` 명령어로 린트 오류 0개 달성.
- [ ] **[0-4. 소스 정합성]** 기능 분리 후 기존 UI(Step 2 Screen)와의 연동 테스트 (기능 누락 여부 확인).
- [ ] 로컬 Git 최종 커밋 수행.

## 4. To-Do List (DEVELOPMENT_RULES 적용)
- [ ] **[0-1. Git 백업]** 구현 시작 전 현재 상태 로컬 커밋 수행
- [ ] `./parts/quiz_file_handler_mixin.dart` 구현 및 테스트
- [ ] `./parts/quiz_ai_assistant_mixin.dart` 구현 및 테스트
- [ ] `./parts/quiz_image_handler_mixin.dart` 구현 및 테스트
- [ ] `quiz_extraction_step2_viewmodel.dart` 슬림화 및 리팩토링 완료
- [ ] **[1-1. 200줄 체크]** 리팩토링 후 모든 관련 파일 라인 수 검증
- [ ] **[3-2. 린트 체크]** `flutter analyze` 스타일/문법 오류 0개 달성
- [ ] **[0-4. 소스 정합성]** `git diff`를 통한 기능 누락 여부 최종 확인
- [ ] **[0-2. Git 최종 커밋]** 완료 후 작업 결과 커밋

## 5. 기대 효과 (Expected Outcomes)
- 기능별 `Mixin` 구조를 통해 코드 중복을 제거하고 기능 확장이 용이해짐.
- 뷰모델 파일 크기가 60% 이상 축소되어 로직 파악 및 유지보수 속도 향상.
- **DEVELOPMENT_RULES.md** 기준을 준수하여 프로젝트 코드 품질 수준 확보.
