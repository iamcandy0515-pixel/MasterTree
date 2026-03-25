# [Plan] 기출문제 일괄 추출 화면 이미지 관리 UI 복구 및 Ctrl+V 기능 구현 (v2)

## 1. 개요 (Overview)
- **목적**: `BulkExtractionScreen`에서 별도의 다이얼로그 없이 **Ctrl+V(붙여넣기)**로 이미지를 즉시 업로드하고, 업로드된 이미지를 **화면 내에서 직접 미리보기(펼치기)** 할 수 있는 고도화된 UI를 복구합니다.
- **준수 규칙**: 
    - [1-1] 단일 파일 200줄 제한 준수 (위젯 분리 필수)
    - [2-2] Socratic Gate를 통한 요구사항 명확화
    - [3-2] `flutter analyze`를 통한 린트 에러 제로 달성

## 2. To-Do List (진행 상황 체크)
- [ ] Phase 1: ViewModel 기능 확장 (`BulkExtractionViewModel`)
- [ ] Phase 2: 이미지 에디터 섹션 분리 (`BulkImageEditorSection.dart`)
- [ ] Phase 3: Ctrl+V 붙여넣기 기능 연동 및 FocusNode 설정
- [ ] Phase 4: 이미지 펼치기/미리보기 UI 완성 및 로딩 피드백
- [ ] Phase 5: 최종 빌드 및 린트 체크 (`flutter analyze`)

## 3. 상세 단계 (Implementation Phases)

### Phase 1: ViewModel 기능 확장 및 데이터 구조 설계
- [ ] `BulkExtractionViewModel`에 클립보드 이미지 처리 로직 추가.
- [ ] `addImageDirectly(int qNum, String field, Uint8List data)` 메서드 구현.

### Phase 2: 편집 섹션 모듈화 (`BulkImageEditorSection.dart`)
- [ ] `BulkExtractionEditorForm`에서 이미지 관리 로직을 별도 파일로 분할.
- [ ] `BulkImageEditorSection` 위젯 생성 (FocusNode 포함).

### Phase 3: 핵심 UI 동작 구현
- [ ] **Ctrl+V 리스너**: `FocusScope` 및 `RawKeyboardListener`를 활용한 클립보드 감지.
- [ ] **인라인 피드백**: '이미지 추가'와 '펼치기' 버튼 배치, 첨부된 이미지 개수 표시.
- [ ] **이미지 리스트**: 펼쳐진 상태에서 이미지의 썸네일과 삭제 버튼 노출.

### Phase 4: 품질 검증
- [ ] `flutter analyze`를 실행하여 모든 린트 이슈 해결.
- [ ] 실제 클립보드 이미지 붙여넣기 동작 전수 검증.

## 4. 리스크 및 사후 점검
- **화면 리플로우**: 이미지가 펼쳐질 때 화면이 밀리는 현상(Layout Shift)을 `Smooth Animation`으로 보정 시도.
- **업로드 안정성**: 네트워크 오류 시 사용자 알림(Snackbar) 연동.
