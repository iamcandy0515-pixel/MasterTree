# Task: Quiz Extraction - UI Flow Refinement & PDF Progress Feedback (v14)

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 정밀 분석

- **유사문제 관리 흐름 (UX)**:
    1. '유사문제 추출' 클릭 -> 추출 완료 시 '추출된 유사 문제: N개 [보기]'만 표시 (메인 화면 리스트 숨김 유지).
    2. **[보기]** 클릭 -> 모달(Dialog) 창에서 불필요한 문제 삭제 관리.
    3. **[닫기]** 클릭 -> 메인 화면 하단 '유사 기출문제' 섹션에 최종 확정된 리스트 노출.
- **카드 UI 포맷 (Main Screen)**:
    - 정보 구성: **'과목 | 년도 | 회차 | 문제번호'** + **'문제 지문'**.
    - 레이아웃: 체계적인 배치를 통해 한눈에 정보를 파악할 수 있도록 구성.
    - **제약 조건**: 모든 정보는 **한 줄(1 line)**을 넘어가면 줄임말(**...**)로 표현하여 레이아웃 무결성 유지.
- **PDF 추출 피드백**:
    - 추출 시작 시: **'추출시작'** 플로팅 메시지.
    - 추출 성공 시: **'추출완료'** 플로팅 메시지.
- **안정성 (Reliability)**:
    - Overflow 방지, 린트 에러 방지, Import 경로 무결성.

## 2. PLANNING (작업 단계별 계획)

### 1단계: 유사문제 UI 제어 상태 도입 (`6_related_question_module.dart`)

- `bool _showFinalList = false;` 상태 추가.
- `_recommendSimilar` 성공 시 `_showFinalList = false;`로 설정하여 추출 직후 리스트 노출 방지.
- `_showSimilarQuizzesModal` 호출 시 `await`를 사용하여 다이얼로그가 닫힌 후 `setState(() => _showFinalList = true);` 처리.

### 2단계: 카드 UI 전문화 (`_buildRelatedQuizCard`)

- 메인 화면에 노출되는 카드를 위해 `Row`와 `Expanded` 조합 사용.
- 왼쪽: 배지 형태의 '과목 년도 회차 번호' 정보 (고정폭 또는 Flexible).
- 오른쪽: 문제 지문 텍스트.
- **공통**: `maxLines: 1`, `overflow: TextOverflow.ellipsis` 적용.

### 3단계: PDF 추출 메시지 고도화 (`0_unified_extraction_header.dart`)

- `startBatchExtractionAction` 실행 직전 `_showFloatingMessage(context, '🚀 추출시작');` 추가.
- 실행 완료 후 `_showFloatingMessage(context, '✅ 추출완료');` 추가.

### 4단계: 시스템 안정성 검증

- 비동기 로직 내 `mounted` 체크 적용.
- `const` 생성자 최적화로 린트 에러 방지.
- 레이아웃 Overflow 테스트 (긴 지문 데이터 입력).

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Condensed Information Design**: 정보량이 많아도 한 줄로 압축하여 표시함으로써 화면의 수직 사용 공간을 효율적으로 관리.
- **State-Driven Visibility**: 로컬 상태 변수를 통해 추출-검토-확정의 단계를 명확히 분리하여 사용자 조작 실수 방지.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `0_unified_extraction_header.dart`: PDF 추출 전후 메시지 노출 로직 수정.
- [ ] `6_related_question_module.dart`: `_showFinalList` 상태 변수 및 모달 종료 후 전환 로직.
- [ ] `_buildRelatedQuizCard`: 1라인 제한 및 줄임표 적용 UI 구현.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **정보 유실**: 1라인 제한으로 인해 지문 전체를 보지 못함 -> 이미 모달에서 전체 내용을 확인했으므로 메인 화면에서는 '식별용' 리스트로 활용하는 것이 의도에 부합함.
- **반응형 대응**: 화면 폭이 좁은 환경(작은 크롬 창 등)에서 배지 영역이 지문을 너무 가리지 않도록 비율 조정 필요.
