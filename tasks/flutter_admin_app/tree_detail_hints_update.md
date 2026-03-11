# 수목 상세화면 힌트 텍스트 박스 기능 추가

## 작업 기록 (Plan)

- **목적:** 수목 상세화면에서 관리자가 각 카테고리별 사진과 관련된 '힌트(단서)'를 직접 수정하고 저장할 수 있도록 기능을 고도화.
- **범위:**
    1. `TreeDetailScreen`에서 기존 "수피", "잎" 사진 전용 레이아웃을 제거.
    2. "기본 정보" 상단에 `미리보기` 텍스트 버튼을 추가하여, 수피/잎의 사진 및 수정 중인 힌트를 다이얼로그로 확인 가능하게 구성.
    3. 전체 카테고리 (대표, 수피와 가지, 잎, 꽃, 열매와 겨울눈)의 힌트 텍스트를 입력받을 수 있는 세로 레이아웃의 입력 상자(TextField) 5개 배치.
    4. 최하단에 `저장` 텍스트 버튼을 추가하여 DB 업데이트(`TreeRepository().updateTree()`) 연동.

## 실행 (Execute)

- `flutter_admin_app/lib/features/trees/screens/tree_detail_screen.dart` 파일을 전체 반영 수정.
- `StatelessWidget`이었던 페이지를 `StatefulWidget`으로 마이그레이션 적용.
- 5종류의 텍스트 컨트롤러(`main`, `bark`, `leaf`, `flower`, `fruit`)를 연결, 기존 힌트가 있을 시 불러오도록 로직 연결 완료. (특히 겨울눈(`bud`, `winter_bud`) 역시 열매(`fruit`) 칸을 통해 동시에 관리되도록 연계됨)

## 사후 점검 및 리스크 분석 (Review & Risk Analysis)

- `api/trees/:id` PUT 메서드를 통해 나무 정보를 수정한 뒤 `tree_images` 내의 각 `hint` 속성을 일괄 업데이트하는 방식으로 동작합니다. 이때, 업로드되어 있는 이미지 중 선택되지 않았거나 빠진 카테고리가 없는지, 백엔드가 `TreeImage` 교체(기존 이미지 제거 후 bulk insert)를 수행할 때 기존 이미지 URL 등이 소실될 가능성이 있는지에 대항하는 점검이 필요하지만, 현재 구현상 기존 `tree.images`를 복사(copyWith)하여 보내도록 구성되어 안정적입니다.
- **스크롤 UI 고려:** 힌트 텍스트 필드가 많아져서 화면 하단에 가려지지 않도록 `SingleChildScrollView`를 통해 접근성이 보장됨을 확인했습니다.
