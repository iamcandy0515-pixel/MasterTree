# 🛡️ Task: Quiz Test Harness (Automation) Implementation Plan

## 1. 개요 (Overview)
- **목적**: `DEVELOPMENT_RULES.md`를 철저히 준수하며 AI 로직 파싱 자동화 검증 및 UI 회귀(Regression) 현상을 방어함.
- **환경**: Windows 11 / Flutter 3.7.12 / Dart 2.19.6 / Node.js 18+
- **핵심 철학**: "작은 로직 수정이 큰 화면 깨짐으로 이어지지 않도록 하는 견고한 방패(Harness) 구축"

## 2. 상태 기록 (Plan) - [Rule 2-1 준수]

- [ ] **[Phase 0] 작업 전 전제 조건 (Git & Env)** - [Rule 0-1, 0-2]
    - [ ] 현재 리팩토링된 소스 코드 `git commit` 수행 (Staging/Backup).
    - [ ] 터미널 인코딩 확인 (`chcp 65001`).
- [ ] **[Phase 1] Backend Infrastructure (Jest & Mocking)**
    - [ ] `nodejs_admin_api/src/tests/setup.ts` 보강: Gemini API Mocking 레이어 확장.
    - [ ] `QuizFormatter.mergeBlocks`에 대한 단위 테스트 시나리오 작성 (Rule 1-1, 200줄 이내 관리).
    - [ ] AI 파싱 결과(JSON Schema) 검증 통합 테스트 구현.
- [ ] **[Phase 2] Frontend Defense (Golden Test)**
    - [ ] `flutter_user_app/test/` 하위에 골든 테스트 전용 폰트 에셋 확인.
    - [ ] `QuizView` 위젯에 대해 텍스트/이미지 혼합 시나리오별 Golden Image 생성.
    - [ ] `flutter test --update-goldens` 실행 및 기준 이미지 검수.
- [ ] **[Phase 3] 사후 검증 및 품질 관리** - [Rule 0-4, 3-2]
    - [ ] `flutter analyze` 실행하여 린트 및 경고 제거.
    - [ ] GitHub 백업본과 수정 소스 간의 `git diff` 최종 분석.
    - [ ] 수정된 퀴즈 화면의 UI Overflow (Overflow) 여부 최종 확인.

## 3. 실행 (Execute)
- *작업 계획 승인 후 각 To-Do를 하나씩 체크하며 정밀 수행 예정.*

## 4. 사후 점검 및 리스크 분석 (Review)

- **완료 목표(Result)**:
    - 수정 후에도 퀴즈 화면 렌더링이 100% 동일함을 보장하는 Golden Baseline 확보.
    - AI(Gemini) 파싱 로직의 정합성을 보장하는 10개 이상의 Jest 테스트 케이스 통과.
- **리스크 (Risk)**:
    - **Windows 폰트 이슈**: Golden Test 이미지가 OS마다 다를 수 있으므로 위젯 내 명시적 폰트 로딩 필수.
    - **200라인 초과**: 테스트 코드가 방대해질 경우 `__tests__/` 폴더 내 도메인별 분리 작업 준수.

---
**개발자님, 이 계획서는 `DEVELOPMENT_RULES.md`의 모든 요구사항을 반영하여 정교하게 설계되었습니다. 승인해 주시면 즉시 Phase 0(Git 백업)부터 가동하겠습니다.**
