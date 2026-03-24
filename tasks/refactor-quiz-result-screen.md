# 🧩 화면 리팩토링 및 기술 명세 준수 계획서: QuizResultScreen

본 계획서는 `DEVELOPMENT_RULES.md` 및 `FLUTTER_3_7_12_TECH_SPEC.md`의 모든 기술 사양과 작업 규칙을 통합하여 작성되었습니다.

## 1. 개요 및 목적
- **작업 대상**: `flutter_user_app/lib/screens/quiz_result_screen.dart`
- **현 상태**: 214라인 (200줄 초과), 계산 로직(`avgHints`) 및 UI 렌더링 코드 혼재.
- **최종 목표**: `parts` 컴포넌트화를 통해 150라인 이하로 감축, `Flutter 3.7.12 / Dart 2.19.6` 환경에서의 완벽한 호환성 및 모바일 로드 부하 최적화.

## 2. 기술 명세 준수 현황 (Rule & Tech Spec)
- **SDK**: Flutter `3.7.12`, Dart `2.19.6` 고정 준수.
- **Java**: `OpenJDK 17` 환경 확인 (Build Error 사전 예방).
- **Design Structure**: `flutter_user_app/core/design_system.dart` 의 테마 및 컬러 토큰(`AppColors`) 철저 활용.
- **Encoding**: 터미널 작업 시 `chcp 65001`을 통한 UTF-8 환경 유지.

## 3. 상세 To-Do List

### 🟢 1단계: 사전 보안 및 백업 (Rule 0-1, 0-2)
- [ ] 현재 상태 로컬 Git 커밋 (`feat: pre-refactor backup for QuizResultScreen`)
- [ ] 터미널 인코딩 설정 확인 (`chcp 65001`)

### 🟡 2단계: 위젯 분리 및 로직 이전 (Rule 1-1, 1-3)
- [ ] `flutter_user_app/lib/screens/parts/` 서브 디렉토리 구조 생성.
- [ ] **result_title_section.dart** 분리: 아이콘, 제목, 설명부를 통합하는 상단 UI 파트화.
- [ ] **result_stat_card.dart** 분리: 정답률 및 힌트 사용량 등의 통계 상세 정보를 담는 카드 위젯화.
- [ ] **로직 이전**: UI 내의 `avgHints` 계산 로직을 `QuizResultController`로 이전하여 UI 순수성 확보.

### 🟠 3단계: 메인 화면 정리 및 성능 최적화 (Rule 3-1, 4-4)
- [ ] **[Clean Code]**: 메인 스크린은 150라인 이하로 감축 및 컴포넌트 조합 구조로 개편. `[Rule 3-1]`
- [ ] **[const 최적화]**: 모든 정적 요소 및 스타일 정의에 `const`를 적용하여 렌더링 성능 가속.
- [ ] **[웹 격리]**: `[Rule 4-4]`에 따라 어떠한 경우에도 `dart:html` 등을 직접 import 하지 않도록 체크.

### 🔴 4단계: 최종 검증 (Rule 2-3, 3-2)
- [ ] **[빌드]** `flutter build web` 또는 apk 빌드를 통해 컴파일 오류 확인.
- [ ] **[린트]** `flutter analyze` 실행하여 모든 경고 및 `prefer_final_fields` 이슈 해결.
- [ ] **[정합성]** 퀴즈 종료 시 실제 결과 데이터(정답수, 힌트수 등)가 정확하게 렌더링되는지 최종 기능 테스트.

---
**최종 승인 요청**: 위 기술 명세 및 규칙을 모두 준수하여 리팩토링을 진행하고자 합니다. 승인해 주시면 작업을 시작하겠습니다.
