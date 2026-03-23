# 🧩 뷰모델 리팩토링 및 기술 명세 준수 계획서: QuizReviewDetailViewModel

본 계획서는 `DEVELOPMENT_RULES.md` 및 `FLUTTER_3_7_12_TECH_SPEC.md`의 모든 기술 사양과 작업 규칙을 통합하여 작성되었습니다.

## 1. 개요 및 목적
- **작업 대상**: `lib/features/quiz_management/viewmodels/quiz_review_detail_viewmodel.dart`
- **현 상태**: 246라인 (200줄 초과), AI/미디어/UI 로직 혼재.
- **최종 목표**: `part` 분할을 통한 120라인 이하 감축, `Flutter 3.7.12 / Dart 2.19.6` 환경에서의 완벽한 호환성 및 모바일 로드 부하 최적화.

## 2. 기술 명세 준수 현황 (Rule & Tech Spec)
- **SDK**: Flutter `3.7.12`, Dart `2.19.6` 고정 준수.
- **Java**: `OpenJDK 17` 환경 확인 (Build Error 사전 예방).
- **Library**: `supabase_flutter: ^1.10.3`, `provider: ^6.0.5`, `http: ^0.13.6` 등 명세에 정의된 검증된 버전 활용.
- **Encoding**: 터미널 작업 시 `chcp 65001`을 통한 UTF-8 환경 유지.

## 3. 상세 To-Do List

### 🟢 1단계: 사전 보안 및 백업 (Rule 0-1, 0-2)
- [ ] 현재 상태 로컬 Git 커밋 (`feat: pre-refactor backup for QuizReviewDetailViewModel`)
- [ ] 터미널 인코딩 설정 확인 (`chcp 65001`)

### 🟡 2단계: 소스 분할 및 구조 설계 (Rule 1-1, 1-3)
- [ ] `quiz_management/viewmodels/parts/` 서브 디렉토리 구조 생성.
- [ ] **quiz_ai_logic.part.dart** 분리: `aiReview`, `generateDistractors`, `recommendSimilar` 등 AI 관련 로직 추출.
- [ ] **quiz_media_logic.part.dart** 분리: `uploadImage`, `removeImage` 등 미디어 처리 로직 추출.
- [ ] **quiz_ui_state.part.dart** 분리: 화면 확장(`toggleExpanded`), 텍스트 파싱(`_extractTextFromBlocks`), 관련 퀴즈(`removeRelated`) 등 UI 부속 동작 추출.

### 🟠 3단계: 메인 뷰모델 정리 및 성능 최적화 (Rule 3-1, 4-4)
- [ ] **[Clean Code]**: 메인 클래스에는 필드 정의, `loadQuiz`, `saveQuiz` 등 핵심 비즈니스 로직만 유지. `[Rule 3-1]`
- [ ] **[타입 최적화]**: `dynamic` 타입을 가능한 모델 클래스로 교체하여 Dart 2.19.6 환경에서의 타입 안정성 강화.
- [ ] **[웹 격리]**: `[Rule 4-4]`에 따라 어떠한 경우에도 `dart:html` 등을 직접 import 하지 않도록 체크.

### 🔴 4단계: 최종 검증 (Rule 2-3, 3-2)
- [ ] **[빌드]** `flutter build web` 실행하여 컴파일 오류 및 빌드 완결성 확인.
- [ ] **[린트]** `flutter analyze` 실행하여 모든 경고(특히 `prefer_final_fields`) 해결.
- [ ] **[정합성]** 기능 동작(AI 검수, 이미지 업로드 등)이 이전과 동일한지 최종 확인.

---
**최종 승인 요청**: 위 기술 명세 및 규칙을 모두 준수하여 리팩토링을 진행하고자 합니다. 승인해 주시면 작업을 시작하겠습니다.
