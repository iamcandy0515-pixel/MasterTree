# 현재 작업 현황

## [1] 작업 계획

- 목표:
    1. 관리자 퀴즈 기출 연동 2단계 화면의 '문제 생성' 버튼을 '문제 등록'으로 변경하고 위치를 '추출 데이터 상세' 옆으로 이동.
    2. '문제' 헤더 옆에 과목명, 년도, 회차, 문제번호 정보를 함께 표시.
    3. AI 해설 추출 시, 계산 문제인 경우 원문을 그대로 번역하지 않고 AI가 직접 풀이를 해설하는 방식으로 프롬프트 수정.
- 범위:
    - `flutter_admin_app/lib/features/quiz_management/screens/quiz_extraction_step2_screen.dart`
    - `flutter_admin_app/lib/features/quiz_management/screens/widgets/quiz_extraction/3_question_explanation_module.dart` (or `7_db_registration_module.dart`)
    - `nodejs_admin_api/src/modules/quiz/quiz.service.ts`

## [2] 세부 작업 내용

- [x] `quiz-ui-update.md` 파일 생성
- [x] Flutter UI: 7번 모듈의 버튼을 2단계 메인 스크린 헤더 영역으로 이동 및 텍스트 수정 ('문제 등록').
- [x] Flutter UI: 3번 모듈의 '문제' 텍스트 옆에 메타데이터(과목명, 연도, 회차, 문제번호) 표시 기능 확장 (산림필답의 특수 조건 포함).
- [x] 백엔드 AI 프롬프트 수정: `extractQuizFromPdfBuffer` 함수에서 '계산 문제일 경우 AI가 직접 단계별 풀이 과정을 해설하도록' 프롬프트 개선.

## [3] 결과 분석 및 위험 요인

- **결과:**
    - `퀴즈 기출 연동` 메뉴의 관리자 UI가 최적화됨. (버튼 위치 및 이름 변경, 추출 데이터 상세 정보 표시)
    - PDF에서 계산 문제 파싱 시, 불친절한 원문 대신 AI가 논리적이고 친절한 풀이 과정을 제공하도록 개선 완료.
- **리스크 분석:**
    - AI에게 '계산 문제의 풀이 과정을 스스로 해설하라'고 재량권을 주었기 때문에, **AI 환각(Hallucination)**으로 인해 잘못된 공식을 사용하거나 계산 실수를 할 리스크가 일부 증가함. (관리자가 화면에서 최종 컨펌/수정해야 함)
    - `DbRegistrationModule`의 버튼이 상단으로 이동하며 스크롤과 무관하게 접근 가능해짐, 단일 화면에서 관리자가 시선 이동 없이 편하게 등록 가능하도록 UI/UX 향상됨.
