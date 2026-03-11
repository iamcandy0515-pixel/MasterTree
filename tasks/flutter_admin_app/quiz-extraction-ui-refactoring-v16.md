# Task: Quiz Extraction - Clean Text Floating Messages (v16)

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 정밀 분석

- **표시 방식**: 기존의 배경색이 있는 `SnackBar`나 `Chip` 형태가 아닌, **배경과 테두리가 없는 순수 텍스트(Clean Text)** 형태로 표시.
- **표시 위치**:
    1. **PDF 추출 메시지**: '문제번호' 레이블 및 넘버박스 바로 아래 영역에 '추출 시작', '추출 완료' 텍스트 표시.
    2. **유사 기출문제 추출 메시지**: '유사 기출문제' 섹션 타이틀 바로 아래 영역에 완료 메시지 표시.
- **디자인 가이드**:
    - 배경색/테두리 없음.
    - 폰트 색상은 강조색(Primary/AI Color)을 사용하되 투명도나 애니메이션을 통해 부드럽게 노출.

## 2. PLANNING (작업 단계별 계획)

### 1단계: 로컬 메시지 상태 관리 구현

- 각 위젯(`0_unified_extraction_header.dart`, `6_related_question_module.dart`)에 `_floatingMessage` 문자열 상태 변수 추가.
- 메시지 출력 후 2초 뒤에 자동으로 빈 문자열로 초기화하는 타이머 로직 구현.

### 2단계: PDF 추출 섹션 UI 수정 (`0_unified_extraction_header.dart`)

- '문제번호' Row 아래에 메시지가 들어갈 고정 높이(`SizedBox` 등) 확보.
- `AnimatedOpacity`를 적용하여 텍스트가 나타나고 사라질 때 부드러운 효과 부여.
- 텍스트 스타일: `fontSize: 12`, `color: primaryColor(녹색)`.

### 3단계: 유사문제 추출 섹션 UI 수정 (`6_related_question_module.dart`)

- '유사 기출문제' 타이틀 아래에 메시지 슬롯 추가.
- 텍스트 스타일: `fontSize: 12`, `color: aiColor(보라색)`.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Fixed-Height Slot**: 메시지가 나타날 때 하단 UI가 밀려나는 'Layout Jitter'를 방지하기 위해, 메시지가 없을 때도 동일한 높이의 빈 공간을 유지하거나 `Stack`을 활용.
- **Clean Aesthetic**: 장식적 요소를 모두 배제하여 정보값(텍스트)만 강조함으로써 모던하고 전문적인 느낌 유지.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `0_unified_extraction_header.dart`: `_headerMessage` 상태 추가 및 문제번호 하단 UI 구현.
- [ ] `6_related_question_module.dart`: `_moduleMessage` 상태 추가 및 타이틀 하단 UI 구현.
- [ ] 메시지 노출 및 자동 소멸 로직(2초) 적용.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **가시성 확보**: 배경색이 없으므로 배경 어두운 톤(`surfaceDark`)과 대비되는 밝은 강조색(Primary/AI Color) 활용 필수.
- **중복 출력 방지**: 짧은 시간 내 여러 번 클릭 시 메시지가 겹치지 않도록 직전 타이머를 취소하는 로직 적용.
