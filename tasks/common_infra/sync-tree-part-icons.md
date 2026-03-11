# 수목 이미지 수집 화면 부위별 데이터 아이콘 동기화 작업 (sync-tree-part-icons)

## 1. 개요

'수목 이미지 수집' 화면(`TreeSourcingScreen`)에서 '부위별 데이터' 아이콘들이 실제 DB(`tree.images`)의 상태와 수집 작업 중인 상태(`pendingImages`)를 정확히 반영하여 활성화(점등) 및 비활성화되도록 수정.

## 2. 작업 대상

- 파일: `d:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib\features\trees\screens\tree_sourcing_screen.dart`

## 3. 주요 수정 내역

1. **아이콘 그룹 전체 Opacity 비활성 제거**:
    - 기존에는 `tree.images.isEmpty` 일 경우 전체 속성값을 `Opacity(0.3)`으로 강제로 낮춰서 개별 데이터가 반영되지 못하는 혼동이 있었습니다. 이를 완전 제거하여 독립적으로 아이콘들이 동작하게 하였습니다.
2. **`_hasImageType` 로직 고도화 및 DB/작업 상태 동기화**:
    - `vm.pendingImages` 검사: 현재 로컬에서 불러온/붙여넣은 (아직 저장되지 않은) 이미지도 바로 활성화 반영되도록 수정 (`UI UX 향상`).
    - `tree.images` DB 검사 강화: `img.imageUrl.isNotEmpty` 검사를 추사하여 DB상 비정상적인 빈 데이터로 인한 오류 방지.
    - `bud` <-> `winter_bud` 호환 로직: 기존 데이터베이스에 '겨울눈'이 'winter_bud'로 저장된 경우와 'bud'로 저장된 경우가 혼재할 수 있으므로, 어떤 형태로 요청하든 정상 인식되도록 예외 처리.

## 4. 사후 점검 (Risk Analysis)

- `_hasImageType` 함수에 `BuildContext context` 파라미터가 추가되며 발생하는 위젯 내 시그니처 오류들을 모두 수정 및 재검증 하였습니다 (flutter analyze 통과).
- `bud` 타입의 양방향 호환 검사를 넣었기 때문에 예전 데이터와 앞으로 입력될 데이터 모두 아이콘 UI에 정확히 반영될 것입니다.
