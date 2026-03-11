# Task: 기출문제 추출(건별) UI 리팩토링 및 기능 고도화

## 1. ANALYSIS (연구 및 분석)

- **Objective**: '퀴즈 상세 추출 및 검토' 화면을 '기출문제 추출(건별)'로 변경하고, 범위 추출 방식을 단일 문항(건별) 처리 방식으로 전환.
- **Key Changes**:
    - 화면 타이틀 변경: '기출문제 추출(건별)'
    - 범위 설정(Start~End) 제거 및 단일 문제 번호(1~15) 선택 Dropdown 도입.
    - 'PDF 추출' 버튼 클릭 시 선택된 특정 문제 번호만 추출하도록 로직 변경.
    - 'DB 저장' 후 다음 문제 번호로 자동 전환 및 데이터 로드 유지.
    - `HintModule` 등에서 발생하는 `Index out of range` 오류 해결.

## 2. PLANNING (작업 단계별 계획)

### 1단계: ViewModel 고도화 (`quiz_extraction_step2_viewmodel.dart`)

- `extractSingleQuizAction` 추가 또는 기존 `startBatchExtractionAction`을 단일 문항 대응용으로 수정.
- `selectedQuestionNumber` 변경 시 메모리에서 데이터를 즉시 로드하는 로직 안정화.
- `saveCurrentQuizToDbAction` 시 자동 증가 로직이 단일 번호 선택 dropdown과 동기화되도록 확인.
- `hintsCount` 관련 방어 로직 추가 (Index Error 방지).

### 2단계: 헤더 UI 리팩토링 (`0_unified_extraction_header.dart`)

- 3행의 '범위:' 라벨과 Start-End 입력필드 제거.
- '문제번호:' 라벨과 1~15 선택 Dropdown 배치.
- 'PDF 추출' 버튼을 문제번호 Dropdown 오른쪽 옆으로 이동.
- ViewModel의 `selectedQuestionNumber`와 `updateFilters`를 사용하도록 연동.

### 3단계: 화면 타이틀 및 모듈 연동 수정 (`quiz_extraction_step2_screen.dart`)

- Scaffold의 AppBar 타이틀을 '기출문제 추출(건별)'로 변경.
- 저장 후 컨트롤러 업데이트 로직(문제, 해설, 보기, 힌트)이 새로운 건별 처리 방식에서 매끄럽게 동작하는지 검증.

### 4단계: 버그 수정 (HintModule)

- `vm.hintsCount`가 컨트롤러 리스트 길이를 초과하지 않도록 UI 및 VM 수정.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Single Source of Truth**: `selectedQuestionNumber`가 헤더의 선택 값, 추출 대상, 저장 후 전이 대상을 모두 관장함.
- **Memory-First Navigation**: 번호 변경 시 서버 호출 없이 메모리(`_extractedQuizzes`)에 있는 데이터를 먼저 노출하여 사용자 경험 개선.

## 4. IMPLEMENTATION (구현 계획)

- [ ] ViewModel: `saveCurrentQuizToDbAction` 및 `updateFilters` 로직 점검.
- [ ] Header UI: 범위 필드 제거 및 단일 번호 Dropdown + 버튼 레이아웃 적용.
- [ ] Screen UI: 타이틀 변경 및 저장 후 화면 갱신 로직 최적화.
- [ ] HintModule: 루프 카운트 방어 코드 적용.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **Risk**: 건별 추출 시 매번 서버 요청이 발생할 수 있음 (Chunking 방식 대신 단건 API 요청으로 변경).
- **Check**: 자동 증가된 번호에 데이터가 없을 경우 'PDF 추출'이 필요함을 사용자에게 알리는 시각적 피드백 확인.
