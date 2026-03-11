# Quiz Filter Display Fix & Layout Change

## Goal

- AppBar에는 '기출문제 일람' 타이틀과 '조회' 버튼만 남김
- 과목, 년도, 회차 필터용 드롭다운(ComboBox)은 타이틀 바로 아래 줄(Body 최상단)로 이동 및 배치
- 조회 클릭 시 "조건에 맞는 기출문제가 없습니다"라고 뜨는 버그 원인을 분석하여 실제 DB 데이터가 나오도록 수정

## Execution Steps

1. **버그 원인 파악 및 백엔드(Supabase) 로직 수정**:
    - 기출문제 데이터를 등록할 때 `quiz_exams` (시험 회차 테이블)에 `category_id` 칼럼이 없는데도 백엔드(`quiz.service.ts`)에서 `category_id`를 기준으로 조회/데이터베이스 입력을 쿼리하고 있었음.
    - 이로 인해 Exam(시험) 레코드 생성이 조용히 실패하고, 기출문제(`quiz_questions`) 테이블에는 `exam_id`가 `null`인 상태로 저장되었음.
    - 프론트엔드에서는 `quiz_exams!inner(...)` 쿼리(Inner Join)를 날리기 때문에 `exam_id`가 없는(연결이 끊긴) 질문은 검색 결과에서 강제 필터링되어 "조건에 맞는 기출문제가 없습니다"라고 나타남.
    - 수정: `nodejs_admin_api/src/modules/quiz/quiz.service.ts` 내의 `quiz_exams` 쿼리에서 존재하지 않는 `category_id` 조건을 제거하여 올바르게 DB와 교신할 수 있도록 조치함.
    - 더불어 DB에 잘못 저장되어 있던(id: 5) 기존 레코드 데이터를 수동으로 수정하여 `exam_id`가 일치하도록 바인딩함.

2. **프론트엔드 UI/Layout 조정 (`flutter_admin_app/lib/features/quiz_management/screens/quiz_management_screen.dart`)**:
    - AppBar Title: `Row`와 `MainAxisAlignment.spaceBetween`으로 감싸서 한 줄에 '기출문제 일람'과 '조회' 버튼만 남기고 공간을 확보함.
    - Body Top: `Expanded` 컨테이너 위에 새로운 `Container`를 추가하고 그 안에 드롭다운(Combo Box) 3개(과목, 년도, 회차)를 수평(`Row`)으로 균등 배치(`Expanded` 사용)함.
    - 드롭다운 스타일: 박스 디자인과 보더 라인을 살리되 한 화면에 균형있게 출력되도록 `isExpanded: true`를 추가함.

## Result & Risk Analysis (MANDATORY AFTER COMPLETION)

- **결과 (Result):**
    - 백엔드 `quiz_exams` insert 버그를 수정함으로써 정상적인 릴레이션(Relation) 설정이 가능해짐. 수정 이후 '조회' 버튼 클릭 시 실제 기출문제 데이터가 문제 없이 로드됨.
    - UI 레이아웃이 요구사항에 맞게 변경됨. AppBar 공간이 여유로워지고 필터들이 본문 상단에 정돈된 배치로 반영되었음.
- **리스크 분석 (Risk Analysis):**
    - 기존에 저장된 데이터 중 `exam_id`가 누락된 채 들어갔던 레코드들에 대해서만 안 보이던 이슈였으므로 성능 저하나 다른 테이블과의 호환성 충돌 위험은 없음.
    - 드롭다운을 Body 내부로 옮겼기 때문에 가로폭이 매우 좁은 모바일 화면에서는 비율상 텍스트(`isExpanded`)가 약간 잘릴 우려가 있으나, 현재 디자인된 Tablet/Web App 기준에서는 충분한 공간 및 UI를 보장함.
