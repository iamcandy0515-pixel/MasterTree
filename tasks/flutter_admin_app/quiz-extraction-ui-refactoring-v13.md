# Task: Quiz Extraction - Similar Question UI Flow & PDF Progress Feedback Refactoring

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 정밀 분석

- **유사문제 추출 흐름**:
    - '유사문제 추출' 클릭 -> 추출 완료 시 '추출된 유사 문제: N개'와 **[보기]** 버튼만 노출.
    - 추출 직후 메인 화면에 리스트를 노출하지 않아 UI 간결성 유지.
    - **[보기]** 클릭 후 모달창에서 문제를 관리(삭제)하고 **[닫기]**를 누르면 메인 화면 하단에 확정된 리스트 노출.
- **리스트 출력 형식**:
    - '과목, 년도, 회차, 문제번호'와 '문제 지문'을 포함한 세로형 카드 리스트.
- **PDF 추출 메시지**:
    - 'PDF 추출' 버튼 클릭 시 진행 상태를 플로팅 메시지로 알림.
    - 시작 시: **'추출시작'**.
    - 완료 시: **'추출완료'**.
- **안정성 확보**:
    - Overflow 방지, 린트 에러 방지, Import 경로 무결성 준수.

## 2. PLANNING (작업 단계별 계획)

### 1단계: 유사문제 UI 제어 상태 도입 (`6_related_question_module.dart`)

- `bool _showFinalList = false;` 상태 추가.
- `_recommendSimilar` 성공 시 `_showFinalList = false;`로 초기화.
- `_showSimilarQuizzesModal`을 비동기로 처리하여 `await showDialog` 이후 `_showFinalList = true;`로 전환.

### 2단계: 메인 화면 리스트 렌더링 형식 수정

- `_buildRelatedQuizCard` UI를 수정하여 '과목, 년도, 회차, 문제번호'가 한 행에 명확히 표기되도록 변경.
- `_showFinalList`가 true일 때만 리스트를 노출하도록 조건부 렌더링 적용.

### 3단계: PDF 추출 메시지 적용 (`0_unified_extraction_header.dart`)

- `startBatchExtractionAction` 호출 전후에 `_showFloatingMessage` 호출.
- 메시지 내용을 **'추출시작'** 및 **'추출완료'**로 정규화.

### 4단계: 코드 무결성 검증 및 예외 처리

- `mounted` 체크를 통한 비동기 UI 업데이트 보호.
- `Flexible`, `Expanded` 등을 활용하여 텍스트 길이에 따른 Overflow 전수 방어.
- `dart analyze`를 통한 린트 에러 수정.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **UX Feedback Loop**: 추출 단계(시작/진행/완료)와 검토 단계(모달 관리), 확정 단계(메인 출력)를 명확히 분리하여 사용자가 작업 진행 상황을 직관적으로 파항할 수 있도록 개선.
- **State Preservation**: 모달 닫기 후 노출되는 리스트는 백엔드 저장 전의 '리뷰 완료' 상태임을 명시적으로 표현.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `0_unified_extraction_header.dart`: PDF 추출 시작/완료 메시지 추가.
- [ ] `6_related_question_module.dart`: `_showFinalList` 상태 도입 및 리스트 노출 조건 수정.
- [ ] `_buildRelatedQuizCard`: 과목/년도/회차/번호 정보 포함 포맷 수정.
- [ ] 모달 닫기 이벤트와 메인 리스트 동기화 로직 구현.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **UI 레이아웃**: 카드 내 정보량이 늘어남에 따라 가로 폭 부족 현상 발생 가능 -> `Flexible` 및 `maxLines` 설정을 통해 대응.
- **메시지 중첩**: 짧은 시간 내 여러 메시지가 발생할 때 `hideCurrentSnackBar()`를 활용하여 메시지 가독성 확보.
- **데이터 일관성**: 저장 버튼을 누르기 전까지는 로컬 상태만 변경되므로, 사용자가 저장 없이 이탈하지 않도록 주의 안내 필요.
