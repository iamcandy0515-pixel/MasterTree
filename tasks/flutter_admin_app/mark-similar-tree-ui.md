# 기준 78종 이외(비교 전용) 유사수목 구별 UI 적용 (mark-similar-tree-ui)

## 1. 개요 (Plan)

기존에 제안된 **1번 방식**을 채택하여, '리기테타소나무'와 같이 기존 78종 기준에 없는 수목을 구별하기 위해 `isAutoQuizEnabled` (퀴즈 대상 여부) 플래그를 활용하여 **비교전용** 뱃지를 UI에 표시합니다.

## 2. 작업 내용 (Execute)

- **대상 파일**:
    - `flutter_admin_app/lib/features/trees/models/tree_group.dart`
    - `flutter_admin_app/lib/features/trees/screens/tree_group_edit_screen.dart`
    - `flutter_admin_app/lib/features/trees/screens/tree_list_screen.dart`

- **세부 작업**:
    1. **모델 추가 (`TreeGroupMember`)**:
        - 그룹 멤버 구조체에 `isAutoQuizEnabled` 속성을 추가하고, JSON 파싱 시 `trees` 객체의 `is_auto_quiz_enabled` 키 값을 참조하도록 로직 추가.
    2. **수목 탐색 후 멤버 추가 시 연동 (`TreeGroupEditScreen`)**:
        - 수목 리스트에서 그룹으로 픽(Pick)할 때, 해당 수목 인스턴스의 `isAutoQuizEnabled` 상태값을 그룹 멤버 생성 시 복사하도록 적용.
    3. **UI 뱃지 표시 (`TreeListScreen` & `TreeGroupEditScreen`)**:
        - `TreeListScreen` 메인 목록 표시줄의 수목명 옆에 `isAutoQuizEnabled == false` 일 경우 `[비교전용]` 이라는 붉은색 시스템 뱃지를 노출.
        - `TreeGroupEditScreen`의 각 그룹원 요약 표시줄에도 우측에 동일하게 `[비교전용]` 뱃지를 추가.

## 3. 사후 점검 및 스크립트 (Review & Risk Analysis)

- 기존 DB 구조 변경 없이 기존 플래그를 활용하므로 백엔드 구조 안정성이 100% 보존됩니다.
- 퀴즈 출제 로직은 기본적으로 `WHERE is_auto_quiz_enabled = true` 조건으로 가져오도록 API가 설계되어 있으므로 별도의 퀴즈 API 수정 없이 자동 방지됩니다.
- **예상되는 리스크/사이드 이펙트**:
    - 과거에 실수로 퀴즈 노출 범위를 꺼둔(false) 기준 종이 있다면, 버그가 아님에도 `[비교전용]` 이라고 노출될 수 있습니다. 이를 발견할 경우 수동으로 '퀴즈 대상 켬' (isAutoQuizEnabled = true) 으로 수목을 수정해야 합니다.
    - 퀴즈 대상을 수시로 껐다 켰다 하는 경우 '비교 전용'이라는 문구가 논리적으로 안 맞을 수 있으므로 이 필드는 용도를 고정해 사용해야 합니다.
