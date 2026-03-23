# 🧩 리팩토링 및 기술 명세 준수 계획서: question_explanation_module.dart

본 계획서는 `DEVELOPMENT_RULES.md` 및 `FLUTTER_3_7_12_TECH_SPEC.md`의 모든 기술 사양과 작업 규칙을 통합하여 작성되었습니다.

## 1. 개요 및 목적
- **작업 대상**: `lib/features/quiz_management/screens/widgets/quiz_extraction/question_explanation_module.dart`
- **현 상태**: 249라인 (200줄 초과), AI 검수 로직이 위젯 내부에 비대하게 포함됨.
- **최종 목표**: 코드량 100라인 이하 감축, `Flutter 3.7.12 / Dart 2.19.6` 환경에서의 완벽한 호환성 및 성능 최적화 보장.

## 2. 기술 명세 준수 현황 (Rule & Tech Spec)
- **SDK**: Flutter `3.7.12`, Dart `2.19.6` 고정 준수.
- **Java**: `OpenJDK 17` 환경 확인 (Build Error 사전 예방).
- **Library**: `provider: ^6.0.5`, `http: ^0.13.6` 등 명세에 정의된 검증된 버전 활용.
- **Encoding**: 터미널 작업 시 `chcp 65001`을 통한 UTF-8 환경 유지.

## 3. 상세 To-Do List

### 🟢 1단계: 사전 보안 및 백업 (Rule 0-1, 0-2)
- [ ] **[백업]** 현재 상태 로컬 Git 커밋 (`feat: pre-refactor backup`)
- [ ] **[환경]** 터미널 인코딩 설정 확인 (`chcp 65001`)

### 🟡 2단계: 소스 분리 및 모듈화 (Rule 1-1, 1-2, 1-3)
- [ ] `quiz_extraction/parts/` 서브 디렉토리 구조 생성.
- [ ] **QuestionInputSection** 분리: 문제 라벨 및 텍스트 필드, AI 판별 정보 위젯 추출.
- [ ] **ExplanationInputSection** 분리: 해설 라벨, 텍스트 필드, AI 검수 버튼 추출.
- [ ] **AIReviewResultDialog** 분리: 비대한 AI 검역 결과 대화상자를 별도 위젯으로 추출하여 메인 파일 코드량 대폭 감축.
- [ ] **[Callback 구현]**: `[Rule 1-2]`에 따라 부모-자식 간의 이벤트 통신 구조 설계 (로드 부하 방지).

### 🟠 3단계: 성능 최적화 및 Clean Code (Rule 3-1, 4-4)
- [ ] **[const 최적화]**: 모든 정적 위젯 및 스타일 정의에 `const` 적용.
- [ ] **[웹 격리]**: `[Rule 4-4]`에 따라 어떠한 경우에도 `dart:html` 등을 직접 import 하지 않도록 체크.
- [ ] **[모바일 최적화]**: 키보드 팝업 시 `Flexible` 및 `isDense: true` 처리로 UI Overflow 사전 예방.

### 🔴 4단계: 최종 검증 (Rule 2-3, 3-2)
- [ ] **[빌드]** `flutter build web` 실행하여 컴파일 오류 및 빌드 완결성 확인.
- [ ] **[린트]** `flutter analyze` 실행하여 'Critical' 및 'Info' 레벨 이슈까지 점검.
- [ ] **[정합성]** 최종 코드 diff 분석을 통해 의도치 않은 코드 유실 여부 확인.

---
**최종 승인 요청**: 위 기술 명세 및 규칙을 모두 준수하여 리팩토링을 진행하고자 합니다. 승인해 주시면 작업을 시작하겠습니다.
