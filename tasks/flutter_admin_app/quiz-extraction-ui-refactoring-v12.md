# Task: Quiz Extraction - Similar Question UI Flow & Final List Exposure Refactoring

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 정밀 분석

- **추출 직후 상태**:
    - '유사문제 추출' 클릭 시 AI 분석이 완료되어도 메인 화면에 리스트를 즉시 노출하지 않음.
    - '추출된 유사 문제: N개' 메시지와 **[보기]** 버튼만 노출하여 메인 UI의 간결함 유지.
- **모달 결과 반영**:
    - **[보기]** 클릭 후 열리는 모달창에서 문제를 관리(삭제)하고 **[닫기]**를 누르는 시점부터 메인 화면에 리스트를 노출.
- **리스트 출력 형식**:
    - 과목, 년도, 회차, 문제번호와 문제 지문을 포함한 세로형 리스트 카드로 구성.
- **데이터 흐름**:
    - 모달 편집 -> 메인 리스트 노출(리뷰 완료 상태) -> 최종 'DB 저장' 클릭 시 Upsert 수행.

### 1-2. 기술적 해결책

- **로컬 상태 관리**: `_showFinalList`라는 불리언 변수를 도입하여 메인 화면 리스트 노출 여부 제어.
- **모달 반환값 처리**: `showDialog`의 `await` 이후 `setState`를 호출하여 리스트 노출 활성화.
- **UI 보강**: `_buildRelatedQuizCard`가 사용자 요구사항인 '과목, 년도, 회차, 문제번호' 정보를 명확히 담도록 포맷 수정.

## 2. PLANNING (작업 단계별 계획)

### 1단계: 상태 변수 추가 및 초기화 로직 수정

- `_RelatedQuestionModuleState`에 `bool _showFinalList = false;` 추가.
- `_recommendSimilar` (추출 버튼 액션) 수행 시 `_showFinalList = false;`로 초기화하여 추출 직후 리스트 숨김 유지.

### 2단계: 모달 호출 및 노출 전환 로직 구현

- `_showSimilarQuizzesModal`을 비동기(`async`)로 변경.
- 다이얼로그가 닫힌 후(`await showDialog`) `setState(() => _showFinalList = true);` 처리.

### 3단계: 메인 화면 리스트 렌더링 조건부 수정

- 리스트 렌더링 조건을 `if (_showFinalList && vm.relatedQuizzes.isNotEmpty)`로 강화.
- 추출 직후에는 '추출된 유사 문제: N개 [보기]' 정보만 나오도록 UI 배치 조정.

### 4단계: 카드 UI 포맷 정밀화

- 과목, 년도, 회차, 문제번호 정보가 원활하게 표시되도록 `Text` 위젯 포맷팅.
- Overflow 방지를 위해 `Flexible` 및 `TextOverflow.ellipsis` 적용 유지.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **UX Consistency**: 추출 단계와 확정 단계를 분리하여 사용자가 '검토' 과정을 거치도록 유도하고, 검토가 끝난 항목만 메인 화면에 노출하여 신뢰도 향상.
- **Clean Architecture**: `ChangeNotifierProvider.value`를 통한 상태 공유 방식을 유지하여 데이터 동기화 이슈 원천 차단.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `6_related_question_module.dart`: `_showFinalList` 상태 도입 및 조건부 렌더링 적용.
- [ ] `_showSimilarQuizzesModal`: `await` 처리 및 닫기 후 상태 업데이트.
- [ ] 메인 리스트 카드 텍스트 포맷 수정.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **상태 유실**: 추출만 하고 모달을 열지 않은 상태에서 저장할 경우, 사용자가 내용을 보지 않고 저장하게 됨 -> 저장 버튼 클릭 시 경고 또는 모달 필수 오픈 유도 여부 검토(현재는 저장 허용).
- **레이아웃 깨짐**: 정보량이 많아졌을 때 세로 리스트의 높이가 너무 커지지 않도록 `ListView.builder`의 `shrinkWrap` 옵션 및 패딩 세밀 조정.
