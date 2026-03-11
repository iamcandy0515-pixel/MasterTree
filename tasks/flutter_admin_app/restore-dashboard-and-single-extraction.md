# 관리자 대시보드 및 건별 추출 화면 복구 작업 계획서

## 1. 개요 및 목적 (Plan)

- **목적:** 관리자 대시보드의 사용성을 높이기 위해 직관적인 버튼 명칭으로 리팩토링하고, 대시보드에서 접근이 누락된 '기출문제 추출(건별)' 화면을 복구합니다.
- **최신화 연계:** 최근 일괄 추출(`BulkExtractionScreen`)과 상세 검토 화면에 반영된 "복합 블록(텍스트+이미지) 렌더링", "이미지 관리 UI(클립보드 붙여넣기 지원)", "Floating SnackBar를 이용한 진행 상태 알림" 등의 최신 작업 이력을 건별 추출 화면에도 동일하게 반영하여 시스템 UI/UX 표준을 통일합니다.

## 2. 작업 범위 (Scope)

### Phase 1: 관리자 대시보드(`dashboard_screen.dart`) UI 및 명칭 수정

- **메뉴 명칭 직관화:**
    - 기존의 모호한 명칭('이미지 수집' 등)을 실제 업무 역할에 맞게 변경 (예: '이미지 수집' -> '수목 이미지 소싱 관리')
    - 'PDF 일괄추출' -> '기출문제 일괄 추출 (PDF)'
- **메뉴 복구:**
    - `QuizExtractionStep2Screen`으로 이동하는 바로가기 버튼('기출문제 추출(건별)')을 대시보드 Grid 또는 List 내에 추가 확보.

### Phase 2: '기출문제 추출(건별)' 기능 최신 버전으로 복구

- **관련 디렉터리:** `lib/features/quiz_management/screens/widgets/quiz_extraction/` 모듈 및 `quiz_extraction_step2_viewmodel.dart`
- **데이터 구조 개편 (Hybrid Content 적용):**
    - 기존 `String` 형태의 `question`, `explanation` 데이터를 `content_blocks`, `explanation_blocks` (텍스트/이미지 분리배열) 형태로 요청 파라미터 업데이트 적용.
- **이미지 업로드 컴포넌트 통합:**
    - 최근 일괄추출에서 수정된 `ImageManagerDialog` 로직을 가져와 건별 추출의 문제/설명 입력 모듈에 통합시켜 클립보드 이미지 붙여넣기 기능 활성화.
- **피드백 UI 일관성 처리:**
    - 이전의 일반 다이얼로그 팝업들을 제거하고, 일괄 추출 화면과 동일 형태의 `Floating SnackBar` 및 중앙 `Container Overlay` 방식을 통해 서버 동작(오답, 힌트 AI 생성 및 DB 등록 등) 진행률을 표시.

### Phase 3: Linter 점검 및 통합 테스트

- `flutter clean` 및 `flutter pub get` 재수행 후, Flutter 최신 문법(예: `withValues(alpha: ...)`)에 위배되는 Deprecated 사항들 일괄 정리.

## 3. 사후 점검 및 리스크 분석 (Risk Analysis)

- **상태 관리 파편화 위험:** 건별 추출 화면(`QuizExtractionStep2Screen`)은 UI 구현이 7개의 하위 모듈 위젯(1번~7번)으로 잘게 쪼개져 있습니다. 각 모듈이 최신 블록 데이터 스키마를 제대로 주고받도록 뷰모델 업데이트 시 꼼꼼히 점검하지 않으면, 특정 단계(예: 오답 생성 모듈 등)에서 String 형변환 에러가 발생할 가능성이 높습니다.
- **Node.js API 하위 호환성:** 건별 단일 등록 API(`/upsert`)가 최신 `content_blocks` 스키마를 수용하도록 프론트엔드의 전송 페이로드(`Json` 변환) 포맷을 반드시 점검해야 합니다.

## 4. 완료된 결과 (Result)

- `DashboardScreen` 의 불명확한 네비게이션 이름들이 비즈니스 로직에 알맞게 업데이트되었습니다. (PDF 일괄 추출, 수목 이미지 소싱 관리).
- 대시보드 내 누락되었던 **기출문제 추출 (건별)** 화면 숏컷을 정상 배포하였습니다.
- 단일 추출 ViewModel 을 하이브리드 블록 구조 (`content_blocks`, `explanation_blocks`)에 맞추어 완전히 리팩토링 하였습니다 (`QuizExtractionStep2ViewModel`).
- 일괄추출 모듈에 구축되었던 이미지 매니저를 `SingleQuizImageManagerDialog` 형태로 분리하여 단일 추출 컨트롤러(`QuestionExplanationModule`)에 이식했습니다. Ctrl + V 클립보드 이미지 지원이 정상 도입되었습니다.
- 단일 문제 DB 업로드(`DbRegistrationModule`)의 UX를 일괄 피드백 모듈과 동일한 `Floating SnackBar`로 통합하여 일관성 있는 디자인 패턴을 구성하였습니다.

## 5. 향후 문제점 및 리스크 분석 (Risk Analysis)

- **유사 기출문제 추천 컴포넌트 하위 호환성:** 현재 뷰모델의 블록 데이터 통합 시, 기존 텍스트 기반 문자열만 예상하던 `distractor_module` 이나 AI 서버 엔드포인트에서 배열/블록 객체를 읽으려다 `TypeError` 나 `Format Exception` 을 발생시킬 소지가 남습니다. 차후 AI 오답/해설 생성 과정 중 텍스트 필터링 구조 개선이 요구됩니다.
- **`SingleQuizImageManagerDialog` 코드 중복:** 일괄 추출에 쓰이던 매니저 다이얼로그와 로직이 대다수 일치하므로 차후 `Mixin` 또는 포괄적인 Base ViewModel 상속 구조에 맞추어 보일러플레이트를 줄이는 아키텍처 리팩토링이 필요합니다.
