# 🛡️ Task: Quiz Test Harness (Automation) Implementation Plan

## 1. 개요 (Overview)
- **목적**: AI 추출 로직 정합성 검증 및 UI 회귀(Regression) 현상 선제적 차단.
- **환경**: Windows 11 / Monorepo
- **철학**: "시스템의 안정성을 보장하는 견고한 방패(Harness) 구축"

## 2. 심층 분석 결과 (Source Analysis)
- **Backend**: `QuizFormatter.mergeBlocks` (이미지 보존 로직) 및 `QuizAIService` 파싱 검증이 핵심.
- **Frontend**: `flutter_admin_app` (편집기 안정성) 및 `flutter_user_app` (퀴즈 뷰어 안정성).
- **Setup**: `nodejs_admin_api/jest.config.js` 기반 인프라 확장 필요.

## 3. 상세 구현 계획 (Implementation Tasks)

### 3.1. [Backend] Jest 통합 테스트 고도화
1. **Gemini Mocking 레이어 확장**: `src/tests/setup.ts` 내에 API Mocking 구현.
2. **`QuizFormatter` 단위 테스트**: `mergeBlocks` 및 `extractImagePaths` 엣지 케이스 검증.
3. **`QuizAIService` JSON 스키마 테스트**: AI 응답 데이터의 규격 일치 여부 확인.

### 3.2. [Frontend] Flutter Golden Test 도입
1. **Golden Test 본체 생성**: 퀴즈 렌더링 결과(스크린샷) 비교 로직 작성.
2. **시나리오 테스트**: 텍스트 전용 / 이미지 포함 / 장문 설명문 퀴즈 시뮬레이션.
3. **Windows 11 폰트 최적화**: 프로젝트 내 폰트 파일을 사용하여 렌더링 일관성 확보.

## 4. 수행 로드맵 (Roadmap)
1. **Phase 1 (인프라)**: Backend Mocking 레이어 완성 및 Jest 보강.
2. **Phase 2 (백엔드)**: AI 파싱 로직 핵심 테스트 케이스 구현.
3. **Phase 3 (프론트엔드)**: 퀴즈 화면 Golden Test 도입 및 이미지 생성.
4. **Phase 4 (자동화)**: 전체 테스트 스크립트 정비.

## 5. 승인 및 주의 사항
- **Windows 경로**: `path.join` 사용하여 호환성 유지.
- **API 비용**: 테스트 시 실제 Gemini API 호출 0% 보장.

---
**개발자님, 이 계획서 파일이 생성되면 바로 Phase 1 작업을 시작하겠습니다.**
