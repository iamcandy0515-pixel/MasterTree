# 📝 작업 계획서: '힌트' 및 '오답' 이미지 관리 기능 삭제 및 소스 최적화

## 0. 작업 전제 조건 (DEVELOPMENT_RULES.md 준수)
- **[Rule 0-1. Git 백업]** 작업 시작 전 현재 브랜치 상태 확인 및 필요시 사전 커밋을 진행하여 소스 유실을 방지합니다.

## 1. 개요
현재 '기출문제 추출 일괄' 폼 내 '힌트'와 '오답(대표)' 영역에 들어간 이미지 위젯(`BulkImageEditorSection`)을 제거하고 순수 텍스트 필드로 원복합니다. 아울러 현재 단일 소스 200줄을 초과(229줄)하는 뷰모델의 모듈 구조를 리팩토링하여 시스템 확장성을 높이고 개발 규칙(Rule 1-1)을 강제합니다.

## 2. 세부 To-Do List (Rule 2-1 준수)

- [ ] **To-Do 1: UI 계층 원복 (텍스트 전용 필드로 전환)**
  - 대상 파일: `flutter_admin_app/lib/features/quiz_management/screens/widgets/bulk_extraction/bulk_extraction_editor_form.dart`
  - 내용: '힌트'와 '오답(대표)'에 사용되던 `BulkImageEditorSection`을 제거하고 폼 내부의 `_buildEditField` 텍스트 창으로 교체합니다.

- [ ] **To-Do 2: ViewModel 데이터 저장 구조 단순화 (String 형태)**
  - 대상 파일: `flutter_admin_app/lib/features/quiz_management/viewmodels/bulk_extraction_viewmodel.dart`
  - 내용: `updateQuizContent`에서 `field == 'hint' || field == 'wrong_answer'`일 때, 불필요해진 List(JSON 블록) 파싱 로직을 타지 않고 단순 텍스트 형식(`item[field] = value.toString()`)으로 업데이트되도록 조건부 분기 처리를 수행합니다.

- [ ] **To-Do 3: Utility 파싱 로직 정비**
  - 대상 파일: `flutter_admin_app/lib/features/quiz_management/utils/bulk_data_utility.dart`
  - 내용: `hasImage` 공통 체크 함수 등에서, 이제는 텍스트 형식이 된 `hint`와 `wrong_answer` 데이터를 블록 배열 기반으로 검사하는 `_checkBlocks` 로직을 완전히 제거합니다. 

- [ ] **To-Do 4: 단일 파일 200줄 초과 제한 수정 (Rule 1-1, 1-2 준수)**
  - 대상 파일: `bulk_extraction_viewmodel.dart`
  - 내용: 해당 파일이 현재 229줄이므로 추가적인 로직 분리 작업을 수행합니다(예: `addImageToQuiz`, `addImageBytesToQuiz` 등의 내부 함수들을 `BulkMediaMixin` 등으로 확실히 분리하여 200줄 이내로 규격을 맞춥니다). 분리 후 Import 경로 에러나 콜백 오류가 없는지 사전 점검(Rule 1-3)을 진행합니다. (현재 `BulkMediaMixin`이 import되어 있으나, 아직 로직이 거기에 전부 이동되지 않았거나 길이가 길게 남아 있는 부분을 정리합니다.)

- [ ] **To-Do 5: 품질 향상 및 무결성 빌드 검증 (Rule 3-2, 0-4 준수)**
  - 내용: 
    1. 코드 수정 완료 후, 루트 디렉토리 및 앱 디렉토리 내 터미널에서 `flutter analyze`를 실행하여 잠재적인 Lint 경고나 오류를 완전히 차단합니다.
    2. 수정한 내용 이외에 의도치 않게 삭제된 부분은 없는지 최종 `git diff`를 통해 정합성을 체크합니다.
    3. 이상이 없을 시 로컬 git commit을 최종적으로 수행합니다.
