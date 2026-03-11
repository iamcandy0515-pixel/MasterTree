# Task: 퀴즈 상세 추출 및 검토 UI 리팩토리 v2 (일괄추출 UI 동기화)

## 1. 개요 (Overview)

관리자 앱의 '퀴즈 상세 추출 및 검토' 화면을 'PDF 일괄 추출' 화면의 UI 디자인 가이드라인에 맞춰 개편합니다. 추출 조건을 고정된 텍스트가 아닌 선택 가능한 입력 필드로 전환하고, 작업 효율을 위해 불필요한 섹션 제거 및 데이터 개수를 최적화합니다.

## 2. 작업 범위 (Scope)

- **대상 화면**: `QuizExtractionStep2Screen` 및 하위 모듈들
- **주요 UI 변경**:
    - **AppBar**: '전체 저장' 아이콘/텍스트 -> **'DB저장'**으로 변경
    - **검색 영역**: '파일명 입력' 필드 위주로 레이아웃 조정
    - **추출 조건 (Subject, Year, Round)**: '일괄추출' 화면과 동일하게 **드롭다운 선택 방식**으로 변경
    - **문제 번호 추가**: **1~15번** 선택 가능한 콤보박스(드롭다운) 신규 도입
    - **버튼 명칭**: '퀴즈 추출 시작' -> **'PDF추출'** (TextButton 스타일)
    - **보기 설정**: 정답 1개 + 오답 1개 (**총 2개**)로 고정
    - **힌트 설정**: **총 2개**로 고정
    - **섹션 제거**: 하단 `DbRegistrationModule` (최종 데이터베이스 등록 섹션) **완전 삭제**

## 3. 상세 단계 (Plan)

### Phase 1: ViewModel 및 Screen 기초 공사

- [ ] `_QuizExtractionStep2ScreenContentState`:
    - `_optionControllers` 개수를 5개에서 **2개**로 변경
    - `_hintControllers` 개수를 3개에서 **2개**로 변경
    - `_questionNumberController` 또는 상태 변수 추가 (기본값 1)
- [ ] `QuizExtractionStep2Screen` AppBar:
    - `TextButton.icon` 형태의 'DB저장' 액션 버튼으로 교체

### Phase 2: 검색 및 추출 조건 모듈 수정 (`1_google_drive_search_module.dart`, `2_pdf_extraction_module.dart`)

- [ ] [파일명 입력] 필드와 [과목, 년도, 회차] 드롭다운을 상단에 일렬로 배치 (일괄추출 화면 참조)
- [ ] [문제 번호] 드롭다운 (1-15) 추가 배치
- [ ] '퀴즈 추출 시작' 버튼을 **'PDF추출'** 텍스트 버튼으로 변경 및 로직 연결

### Phase 3: 보기/힌트 모듈 최적화 (`4_distractor_module.dart`, `5_hint_module.dart`)

- [ ] `DistractorModule`: UI 레이아웃을 수정하여 정답 1개, 오답 1개만 입력 가능하도록 조정
- [ ] `HintModule`: 힌트 개수를 2개로 고정하고 UI 업데이트

### Phase 4: 섹션 정리 및 통합 저장 기능

- [ ] `QuizExtractionStep2Screen`에서 `DbRegistrationModule` 호출 제거
- [ ] 상단 'DB저장' 버튼 클릭 시 현재 입력된 모든 정보(조건 + 문제번호 + 추출 데이터)를 수합하여 DB에 저장하는 로직 완성

## 4. 검증 항목 (Verification)

- [ ] '파일명 입력' 및 '과목/년도/회차' 선택 UI가 일괄추출 화면과 동일하게 작동하는가?
- [ ] 문제번호가 1~15번 사이에서 선택 가능한가?
- [ ] 보기가 2개(정답, 오답), 힌트가 2개만 노출되는가?
- [ ] 하단 등록 섹션이 사라지고 상단 'DB저장'으로 통합되었는가?

---

## 사후 점검 (Review)

_(작업 완료 후 작성 예정)_

## Risk Analysis

- 기존 `DbRegistrationModule`이 담당하던 '이 문제만 즉시 저장' 로직을 상단으로 옮길 때, 데이터 유효성 검사(필수값 체크)가 누락되지 않도록 주의.
- 보기 개수 변경 시 기존 5개 기준으로 작성된 테스트 코드나 로직이 있다면 수정 필요.
