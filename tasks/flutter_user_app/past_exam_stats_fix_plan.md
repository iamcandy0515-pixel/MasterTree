# 📋 사용자 앱 기출문제 통계 연동 및 복구 작업 계획서 (V1)

## 1. 개요 및 문제 분석
- **현상**: 사용자 앱의 '나의 학습 통계' 및 관리자 앱의 '상세 통계'에서 '기출문제' 수치가 0으로 표시됨.
- **원인**:
    1. '기출문제' 풀이 화면(`QuizSolverScreen`)이 서버 API가 아닌 **하드코딩된 Mock 데이터**를 사용 중.
    2. 문제 풀이 완료 시 결과를 서버(`quiz_attempts` 테이블)에 저장하는 **API 호출 로직이 누락**됨.
    3. 서버 통계 로직은 DB 레코드 기반이므로, 저장되지 않은 데이터는 집계에서 제외됨.

## 2. 준수 규칙 (DEVELOPMENT_RULES.md)
- 모든 수정은 **200줄 이하**의 파일 단위를 유지 (필요시 위젯 분리).
- 작업 전 **로컬 Git 커밋** 수행.
- 터미널 명령어 실행 전 **인코딩 설정(`chcp 65001`)** 확인.
- 작업 완료 후 **`flutter analyze`**로 코드 품질 검증.

## 3. 세부 작업 단계 (To-Do List)

### Phase 1: 기반 작업 및 백엔드 확인
- [ ] 현재 상태 로컬 Git 커밋 (`feat(user-app): prepare for past exam stats fix`)
- [ ] 백엔드 `/api/user-quiz/generate` 엔드포인트가 'random' 모드를 지원하는지 재확인

### Phase 2: 사용자 앱 API 서비스 고도화
- [ ] `ApiService.generateQuizSession(String mode)` 메서드 추가 (기출문제 로드용)
- [ ] `ApiService.submitQuizAttempt` 메서드 보강 (필요 시 `session_id` 및 `exam_id` 관련 파라미터 대응 확인)

### Phase 3: QuizSolverController 리팩토링
- [ ] 하드코딩된 `questions` 리스트를 제거하고 서버로부터 데이터를 가져오는 `loadQuestions()` 구현
- [ ] `submitAnswer()` 수행 시 `ApiService.submitQuizAttempt()`를 호출하여 실제 결과를 DB에 저장
- [ ] 서버 상태(로딩, 에러)를 관리할 수 있는 변수 추가

### Phase 4: UI 개편 및 소스 분리
- [ ] `QuizSolverScreen`에서 API 로딩 상태 및 에러 화면 처리 로직 추가
- [ ] `QuizSolverScreen` 소스가 200줄을 초과할 경우, 문제 렌더러와 선택지 카드를 별도 위젯 파일로 분리
- [ ] 결과 저장 성공/실패에 대한 사용자 피드백(SnackBar 등) 강화

### Phase 5: 최종 검증
- [ ] `flutter analyze`를 실행하여 린트 오류 수정
- [ ] 실제 기출문제를 풀이한 후 '나의 학습 통계' 탭에서 수치 반영 여부 확인
- [ ] 관리자 앱의 상세 통계 화면에서도 동일한 데이터가 반영되는지 교차 검증

## 4. 예상 일정
- **Phase 1-3**: 약 30분
- **Phase 4-5**: 약 20분
- **합계**: 약 50분 내외

---
**보고자**: Antigravity (AI Coding Assistant)
**승인 여부**: 개발자님의 승인 후 즉시 착수하겠습니다.
