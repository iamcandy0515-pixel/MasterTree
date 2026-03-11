# Task: HintModule Index Error Debugging & Fix

## 1. ANALYSIS (연구 및 분석)

- **Problem**: `HintModule` 빌드 중 `Index out of range: index should be less than 2: 2` 발생.
- **Root Cause**: `QuizExtractionStep2Screen`에서 전달된 `hintControllers`의 길이는 2인데, UI 빌드 시 `vm.hintsCount`가 2를 초과하는 값으로 설정되어 접근하려 함.
- **Evidence**: 스택 트레이스에서 `5_hint_module.dart`의 `List.generate` 내부에서 발생함을 확인.

## 2. PLANNING (작업 단계별 계획)

### 1단계: ViewModel 제어 로직 강화

- `QuizExtractionStep2ViewModel`의 `_hintsCount`가 항상 `hintControllers`의 최대 길이인 2를 넘지 않도록 `setHintsCount`에 방어 로직 추가.
- 추출된 데이터 로드 시 힌트 개수가 많더라도 UI 제어 값(`_hintsCount`)은 2로 고정 유지.

### 2단계: UI 방어 코드 재점검 및 수정

- `5_hint_module.dart`에서 `vm.hintsCount`를 직접 사용하지 않고, 실제 주입된 `hintControllers.length`를 기준으로 루프를 돌림.
- `QuizExtractionStep2Screen`의 저장 후 데이터 로드 로직에서 `_hintControllers`와 `hints` 리스트 간의 길이 차이를 다시 한 번 확인.

### 3단계: 빌드 및 실행 확인

- 오류 발생 지점을 완벽히 제거했는지 `flutter build web` 또는 `flutter run`으로 확인.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Safe List Access**: `List.generate(count, ...)` 사용 시 `count`는 반드시 타겟 리스트의 `length` 이하임을 보장해야 함.
- **ViewModel Responsibility**: UI의 제약 조건(예: 입력 필드 2개)은 ViewModel의 상태 값에도 반영되어 일관성을 유지해야 함.

## 4. IMPLEMENTATION (구현 계획 - 파일별 수정 대상)

- [ ] `lib/features/quiz_management/viewmodels/quiz_extraction_step2_viewmodel.dart`: `setHintsCount` 수정.
- [ ] `lib/features/quiz_management/screens/widgets/quiz_extraction/5_hint_module.dart`: 루프 카운트 로직 수정.
- [ ] `lib/features/quiz_management/screens/quiz_extraction_step2_screen.dart`: 저장 시 데이터 동기화 루프 안전성 확보.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **Side Effect**: 힌트 개수를 3개 이상으로 확장하고 싶은 경우, UI 컨트롤러 리스트와 ViewModel 상태를 동시에 늘려줘야 함. 현재는 2개로 고정됨.
- **Review Item**: 저장 시 `hints` 리스트가 2개보다 적을 경우에 대한 처리(Existing logic covers this but need re-check).
