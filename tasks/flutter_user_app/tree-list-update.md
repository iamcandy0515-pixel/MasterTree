# 수목현황 일람 UI 개선 및 삭제 기능 추가 작업 계획 (tree-list-update)

## 1. 개요

'수목현황 일람' 화면의 불필요한 하단 네비게이션을 삭제하고, 목록 내 각 수목 카드에 개별 삭제 기능을 추가하여 관리 편의성을 높입니다.

## 2. 작업 대상 파일

- `d:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib\features\trees\screens\tree_list_screen.dart`

## 3. 세부 작업 내용

1. **하단 네비게이션 삭제**:
    - `Scaffold`의 `bottomNavigationBar` 속성 제거
    - 불필요해진 `_buildBottomNav` 및 `_buildNavItem` 메서드 삭제
2. **리스트 아이템(카드)에 삭제 버튼 추가**:
    - `_buildListItem` 메서드 내 '화살표(chevron_right)' 아이콘 좌측에 '삭제(delete_outline)' 아이콘 추가
3. **삭제 확인 모달(Dialog) 구현**:
    - 삭제 아이콘 클릭 시 동작할 `_showDeleteDialog(BuildContext context, Tree tree)` 메서드 작성
    - 모달에 '취소', '확인' 버튼 제공
4. **실제 데이터 삭제 연동**:
    - 모달에서 '확인' 버튼 클릭 시 `TreeListViewModel`의 `deleteTree(tree.id!)` 메서드 호출
    - 삭제 완료 후 사용자에게 SnackBar로 "삭제되었습니다." 알림 표시
      _(참고: `TreeListViewModel`에는 이미 `deleteTree` 메서드가 구현되어 있으므로 UI 연결만 수행합니다.)_

## 4. 리스크 및 주의사항 (Risk Analysis)

- 삭제 기능이 직접적으로 노출되므로, 사용자의 실수로 인한 데이터 유실을 방지하기 위해 다이얼로그 텍스트가 명확하게 전달되어야 합니다.
- 삭제 완료 후 리스트가 정상적으로 갱신(Refresh)되는지 뷰모델의 동작과 잘 맞물리는지 체크가 필요합니다.
