# Task: 유사종 비교 상세 화면 AI 힌트 기능 구현

## 1. 상태 기록 (Plan)

- **목적**: 기존의 정적인 '한눈에 구분하기' 정보를 제거하고, 사용자가 필요할 때 AI(Gemini)로부터 두 수종의 비교 힌트를 실시간으로 받아볼 수 있는 인터페이스를 구축함.
- **작업 범위**:
    1.  **백엔드 API 구축**: `nodejs_admin_api`에 `POST /ai/comparison-hint` 엔드포인트 추가 및 Gemini 2.0 Flash 모델 연동.
    2.  **프론트엔드 UI 수정**: '한눈에 구분하기' 위젯을 'AI 힌트 받기' `TextButton`으로 교체.
    3.  **상태 관리 및 비동기 처리**: 힌트 요청 시 로딩 애니메이션 표시, 결과 수신 후 힌트 영역 렌더링.
    4.  **다이내믹 프롬프트**: 선택된 태그('잎', '수피') 정보를 포함하여 맞춤형 힌트 생성.

---

## 2. 실행 (Execute)

- [x] **Backend Update**:
    - `AiService.getComparisonHint` 메서드 구현.
    - `AiController.getComparisonHint` 엔드포인트 연결.
    - `ai.routes.ts`에 라우트 등록 (Public 권한).
- [x] **Frontend Update**:
    - `SpeciesComparisonDetailScreen`에 `http`, `dart:convert` 임포트.
    - `_fetchAiHint` 메서드 및 `_aiHint`, `_isAiLoading` 상태 추가.
    - `_buildQuickDistinctionBox`를 버튼 및 동적 표시 영역으로 전면 개편.
- [x] **Verification**: 서버 재기동 및 UI 정상 동작 확인.

---

## 3. 사후 점검 (Review)

- **완료된 결과(Result)**:
    - **실시간 AI 연동**: 사용자가 버튼을 클릭하면 Gemini AI가 두 수종의 차이점을 즉석에서 분석하여 설명해줍니다.
    - **UI/UX 개선**: 정적인 텍스트 대신 인터랙티브한 버튼을 제공하고, AI 전용 아이콘과 부드러운 박스 디자인으로 프리미엄 느낌을 강화했습니다.
    - **컨텍스트 인식**: 사용자가 선택한 비교 대상(잎/수피)을 AI에게 전달하여 문맥에 맞는 정확한 힌트를 제공합니다.

- **향후 문제점 및 리스크 분석(Risk Analysis)**:
    - **API 비용 및 할당량**: Gemini API 호출 횟수에 따른 비용 발생 및 할당량 제한을 모니터링해야 합니다.
    - **응답 시간**: AI 분석에 보통 1~3초가 소요되므로 사용자에게 로딩 중임을 명확히 인지시키는 UI 피드백을 유지해야 합니다.
    - **오류 처리**: 네트워크 단절이나 AI 서비스 장애 시 '다시 시도' 옵션을 제공하는 것이 좋습니다.
