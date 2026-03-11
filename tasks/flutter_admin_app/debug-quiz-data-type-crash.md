# Task: Quiz Extraction Data Type Crash (String vs List) Debugging & Fix

## 1. ANALYSIS (연구 및 분석)

- **Problem**: `QuizExtractionStep2Screen` 빌드 및 문제 전환 시 `type 'String' is not a subtype of type 'List<dynamic>?'` 및 `NoSuchMethodError: 'where'` 발생.
- **Root Cause**: 백엔드에서 `question` 또는 `explanation` 필드가 블록(List) 형식이 아닌 단순 문자열(String)로 반환될 경우, UI의 `where` 필터링 및 ViewModel의 리스트 처리 로직에서 충돌 발생.
- **Enhancement**: PDF 추출 시 '추출 시작', '추출 완료' 등 작업 상태를 플로팅 메시지로 출력하여 사용자 경험 개선.

## 2. PLANNING (작업 단계별 계획)

### 1단계: ViewModel 데이터 정규화 로직 추가

- `QuizExtractionStep2ViewModel`에 데이터 로드 시 문자열을 리스트 블록으로 강제 변환하는 `_normalizeBlocks` 유틸리티 메서드 추가.
- `startBatchExtractionAction` 및 `loadQuizDataFromMemory`에서 데이터를 매핑할 때 이 유틸리티를 적용하여 내부 상태가 항상 `List`임을 보장.

### 2단계: Screen UI 방어 코드 및 알림 기능 강화

- `_onViewModelChanged` 리스너 내부에서 `vm.currentQuiz['question']` 등이 `List`가 아닐 경우를 대비해 `as List?` 캐스팅과 유효성 검사 추가.
- `String`이 들어왔을 때도 단순 텍스트로 처리할 수 있도록 Fallback 로직 적용.
- 'PDF 추출' 버튼 클릭 시 `_showFloatingMessage`를 호출하여 '🚀 추출을 시작합니다...' 및 완료/실패 메시지 시각화.

### 3단계: ViewModel 편집 메서드 수정

- `updateQuizContent`, `addImageToQuiz` 등 리스트를 전제로 하는 메서드들에서 타입 체크를 수행하여 Crash 방지.

### 4단계: 재기동 및 확인

- 수정 후 `flutter run`으로 문제 번호 전환 시 Crash가 더 이상 발생하지 않는지 확인.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Data Robustness**: 프론트엔드는 백엔드 API 명세가 엄격하지 않을 수 있음을 가정하고, 수신된 데이터의 타입을 강제로 정규화(Normalization)하여 하위 컴포넌트의 안정성을 보장해야 함.

## 4. IMPLEMENTATION (구현 계획)

- [ ] ViewModel: `_normalizeBlocks` 구현 및 데이터 매핑부 적용.
- [ ] Screen: `_onViewModelChanged` 및 저장 시 데이터 로드부 타입 세이프티 강화.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **Risk**: 정규화 과정에서 원본 데이터의 특수 형식이 유실될 가능성 (현재는 단순 텍스트/이미지만 고려).
- **Check**: 이미지 블록이 포함된 경우에도 정규화 로직이 파괴되지 않는지 검증.
