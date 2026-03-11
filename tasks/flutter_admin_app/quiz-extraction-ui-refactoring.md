# Task: 퀴즈 상세 추출 및 검토 UI 리팩토링 및 환경 설정 고도화

## 1. 개요 (Overview)

관리자 앱의 '퀴즈 상세 추출 및 검토' 화면을 사용자가 보다 직관적으로 조작할 수 있도록 UI를 개편합니다. 기존의 정적인 추출 조건 표시 방식을 동적인 입력 방식으로 전환하고, 불필요한 섹션 제거 및 보기/힌트 개수를 최적화합니다.

## 2. 작업 범위 (Scope)

- **대상 화면**: `QuizExtractionStep2Screen` 및 하위 모듈
- **주요 변경 사항**:
    - **추출 조건 (Subject, Year, Round)**: 단순 텍스트 표시에서 수정 가능한 입력 필드로 전환
    - **신규 필드 추가**: '문제 번호(Question Number)' 입력 필드 신규 도입
    - **보기 설정 (DistractorModule)**: 총 5개 보기에서 '정답 1개 + 오답 1개' (총 2개)로 축소
    - **힌트 설정 (HintModule)**: 기본 3개에서 2개로 축소
    - **섹션 제거**: 하단 '최종 데이터베이스 등록' 모듈 (`DbRegistrationModule`) 전체 삭제
    - **상단 액션**: '전체 저장' 아이콘 및 텍스트를 'DB저장'으로 변경 및 기능 연결

## 3. 상세 단계 (Plan)

### Phase 1: ViewModel 및 Screen 기초 공사

- [ ] `QuizExtractionStep2ViewModel`: `selectedSubject`, `selectedYear`, `selectedRound`를 보다 유연하게 관리하고 `questionNumber` 상태 추가
- [ ] `QuizExtractionStep2Screen`:
    - AppBar의 저장 버튼 텍스트를 'DB저장'으로 변경
    - `DbRegistrationModule` 호출 코드 제거 (삭제)
    - '문제 번호'용 `TextEditingController` 추가 및 하위 모듈 전달

### Phase 2: 추출 조건 섹션 고도화 (`2_pdf_extraction_module.dart`)

- [ ] 기존 컨테이너 내부의 텍스트 필드를 `TextField` 또는 `Dropdown` 형태로 변경
- [ ] '문제 번호'를 입력받는 행(Row) 추가

### Phase 3: 보기/힌트 개수 최적화 및 로직 수정

- [ ] `DistractorModule.dart`: 리스트 생성 로직을 `List.generate(2, ...)` 형태로 수정하여 정답 1, 오답 1 유도
- [ ] `HintModule.dart`: 힌트 개수 상한을 2개로 고정하고 드롭다운 항목도 [1, 2]로 조정

### Phase 4: 최종 데이터 흐름 연결 및 검증

- [ ] 'DB저장' 버튼 클릭 시 업데이트된 모든 필드(과목, 년도, 회차, 문제번호, 보기, 힌트 등)를 수집하여 DB에 `upsert` 하도록 연결

## 4. 검증 항목 (Verification)

- [ ] 화면 상단에서 과목/년도/회차/문제번호를 자유롭게 수정할 수 있는가?
- [ ] 보기가 '정답'과 '오답 1' 두 개만 나타나는가?
- [ ] 힌트가 최대 2개까지만 표시되는가?
- [ ] 하단의 '최종 데이터베이스 등록' 섹션이 보이지 않는가?
- [ ] 상단 'DB저장' 버튼으로 데이터가 정상적으로 저장되는가?

---

## 사후 점검 (Review)

_(작업 완료 후 작성 예정)_

## Risk Analysis

- 기존 저장 로직이 `DbRegistrationModule`에 분산되어 있었을 경우, 이를 상단 'DB저장' 버튼으로 통합하는 과정에서 데이터 누락 주의 필요.
- 보기 개수가 5개에서 2개로 줄어듦에 따라 기존 DB 스키마와의 호환성(예: Not Null 제약 등) 확인 필요. (일반적으로 옵션은 리스트 형태이므로 큰 문제 없음)
