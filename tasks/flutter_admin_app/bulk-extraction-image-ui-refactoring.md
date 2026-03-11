# 작업 계획서: 일괄 추출 화면 이미지 관리 UI 개선 (v1)

## 1. 개요

관리자 앱의 '일괄 추출(Bulk Extraction)' 화면에서 문제 및 해설의 이미지 관리 방식을 '기출문제 상세' 화면의 방식과 동일하게 개선합니다. 기존의 다이얼로그 중심 방식에서 벗어나, 화면 내에서 직접 이미지 목록을 펼쳐보고 Ctrl+V로 즉시 붙여넣을 수 있는 직관적인 UI를 제공합니다.

## 2. 주요 변경 사항

### 2.1 UI/UX 개선

- **아이콘 및 버튼 명칭 변경**:
    - '이미지 관리' 버튼 대신 '이미지 추가'(`Icons.add_photo_alternate`)와 '이미지 펼치기/접기'(`Icons.photo_library` / `Icons.keyboard_arrow_up`) 아이콘 버튼 제공.
- **이미지 펼치기(Expand) 기능**:
    - 각 필드(문제, 정답 및 해설) 하단에 '이미지 펼치기' 클릭 시 원본 이미지를 세로 목록으로 표시.
- **이미지 피드백**:
    - 이미지가 첨부된 경우 텍스트 필드와 전송 버튼 사이에 작은 썸네일과 개수 정보를 표시하여 시각적 확인 기능 강화.

### 2.2 기능 개선

- **직접 붙여넣기(Ctrl+V) 지원**:
    - 각 입력 필드에 `FocusNode`를 할당하여, 영역이 포커스된 상태에서 Ctrl+V를 누르면 이미지가 즉시 업로드되도록 구현.
- **이미지 도구 모음 통합**:
    - 텍스트 입력과 이미지 관리를 한 영역에서 효율적으로 처리할 수 있도록 레이아웃 재구성.

## 3. 작업 단계

### 1단계: 상태 변수 및 FocusNode 추가 (`bulk_extraction_screen.dart`)

- `_questionFocusNode`, `_explanationFocusNode` 추가.
- `_isQuestionImagesExpanded`, `_isExplanationImagesExpanded` 상태 필드 추가.
- 이미지 추가 시 피드백을 보여주기 위한 `_showQuestionFeedback`, `_showExplanationFeedback` 상태 관리.

### 2단계: 이미지 붙여넣기 로직 이식

- `ImageManagerDialog`에 있던 `_handlePaste` 및 `_uploadImage` 로직을 `BulkExtractionScreen` 클래스 내부로 이식하여 직접 호출 가능하게 수정.

### 3단계: `_buildEditFieldWithImages` 리팩토링

- 위젯 구조를 `QuizImageEditorSection`의 스타일로 변경.
    - 상단: 라벨 + (이미지 개수 피드백) + 도구 아이콘(추가, 펼치기, 전체삭제).
    - 중간: `TextField`.
    - 하단: (펼쳐졌을 때) `ListView` 형태의 이미지 목록 + `Ctrl+V` 안내 박스.

### 4단계: `BulkExtractionViewModel` 연동 확인

- `addImageToQuiz`, `removeImage` 등의 기존 메소드를 활용하여 데이터 정합성 유지.

## 4. 기대 효과

- **작업 속도 향상**: 다이얼로그를 여닫는 번거로움 없이 즉시 이미지를 확인하고 추가 가능.
- **일관성 확보**: 상세 화면과 동일한 UI 구조를 가짐으로써 사용자의 학습 비용 감소.
- **가독성 개선**: 긴 해설이나 복잡한 이미지도 화면 내에서 한눈에 검토 가능.

## 5. 리스크 및 추후 검토

- **화면 스크롤 관리**: 대용량 이미지가 여러 개 펼쳐질 경우 화면이 길어질 수 있으므로 `SingleChildScrollView` 내에서 원활한 스크롤 보장 필요.
- **메모리 부하**: 다량의 이미지를 동시에 렌더링할 때 성능 저하 여부 체크 (CachedNetworkImage 활용).
