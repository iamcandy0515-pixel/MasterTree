# 📝 작업 계획서: 기출문제 관리 UI 타이틀 텍스트 변경 및 불필요 버튼 삭제

## 0. 작업 전제 조건 (DEVELOPMENT_RULES.md 준수)
- **[Rule 0-1. Git 백업]** 기존 개발 내역 및 작업 전 소스 유실 방지를 위해 로컬 상태 확인 및 사전 `git commit / stash` 수행.

## 1. 개요
관리자 앱 대시보드의 네비게이션과 연결된 두 주요 화면의 타이틀(Appbar Text)을 요구사항에 맞게 변경하여 사용자 경험의 통일성을 맞추고, '기출문제 일람' 화면 상단의 불필요한 '신규 기출등록' 버튼 위젯을 제거하는 작업입니다.

- **변경 1:** '기출문제 관리' ➜ **'기출문제 일람'**
- **변경 2:** '문제 검수 및 상세 편집' ➜ **'기출문제 상세편집'**
- **변경 3:** '기출문제 일람' 폼 헤더의 **'신규 기출등록' 버튼 삭제**

## 2. 세부 To-Do List (Rule 2-1 준수)

- [ ] **To-Do 1: '기출문제 일람' 텍스트 변경**
  - 대상 경로: `flutter_admin_app/lib/features/quiz_management/screens/quiz_management_screen.dart`
  - 내용: 화면 최상단 또는 Appbar 부분에 하드코딩된 `'기출문제 관리'` 텍스트(약 35번째 줄 부근)를 `'기출문제 일람'`으로 수정.

- [ ] **To-Do 2: '기출문제 상세편집' 텍스트 변경**
  - 대상 경로: `flutter_admin_app/lib/features/quiz_management/screens/quiz_review_detail_screen.dart`
  - 내용: 문제 지문 카드 클릭 시 넘어가는 화면의 Appbar 타이틀 `'문제 검수 및 상세 편집'`(약 57번째 줄 부근)을 `'기출문제 상세편집'`으로 수정.

- [ ] **To-Do 3: '신규 기출등록' 버튼 위젯 완전 삭제**
  - 대상 경로: `flutter_admin_app/lib/features/quiz_management/screens/widgets/quiz_parts/quiz_filter_header.dart`
  - 내용: 해당 파일 내 필터링 폼 헤더 부분에 존재하는 `ElevatedButton.icon(label: '신규 기출등록', ...)` 코드를 완전히 제거하여 화면상에 렌더링되지 않도록 조치. 수정과 함께 불필요해진 연관 Layout 패딩(Row/SizedBox 등)이 있다면 깔끔하게 다듬기.

- [ ] **To-Do 4: 품질 무결성 및 Lint 검증 (Rule 1-1, Rule 3-2 준수)**
  - 내용:
    1. 해당 파일들 내 코드를 수정하면서 200줄 초과 위반(Rule 1-1)이 없는지 간단한 점검을 수행. (텍스트 수정 및 버튼 삭제가 주 목적이므로 큰 분리 작업은 없으나 기본 정합성은 유지)
    2. 앱 디렉토리 내 터미널에서 `flutter analyze`를 실행하여 텍스트 교체 원인으로 인한 `const` 경고 등 문법/스타일 에러가 발생하지 않는지 스캔.

- [ ] **To-Do 5: 최종 점검 및 Git Commit (Rule 0-4 준수)**
  - 내용:
    1. 수정한 수치 외에 의도치 않게 삭제되거나 손상된 코드가 없는지 `git diff`를 실행하여 확인.
    2. 이상이 없으면 `"refactor(admin): update quiz management titles and remove new quiz button"` 이라는 메시지로 로컬 Git 커밋 완료. 
