# 관리자 앱 '신규수목등록' 힌트 입력 및 이미지 붙여넣기 기능 구현 계획서

## 1. 개요 (Overview)
관리자 앱에서 수목 데이터를 등록할 때, 각 스마트 태그(대표, 잎, 수피, 꽃, 열매)별로 상세 힌트를 입력할 수 있는 기능을 추가하고, 이미지 등록 시 사용자 편의를 위한 클립보드 붙여넣기(Ctrl+V) 기능을 UI 상에 명확히 구현합니다.

## 2. 주요 변경 사항 (Key Changes)

### 2.1. 데이터 모델 및 ViewModel 고도화
- **TreeMediaMixin (Flutter)**: 
    - 각 업로드된 이미지(`TreeImage`)의 힌트를 개별적으로 수정할 수 있는 `updateImageHint(int index, String hint)` 메서드 추가.
    - 클립보드에서 이미지 감지 시 현재 선택된 이미지 타입(Smart Tag)에 맞춰 자동 업로드 로직 강화.

### 2.2. UI/UX 개선 (AddTreeScreen)
- **이미지 그리드 (AddTreeImageGrid)**:
    - 업로드된 각 이미지 하단에 '힌트' 입력용 `TextField` 배치.
    - 입력된 힌트가 `TreeImage` 객체의 `hint` 필드에 즉시 동기화되도록 구현.
- **업로드 박스 (AddTreeUploadBox)**:
    - "이미지를 클릭 후 Ctrl+V를 눌러 붙여넣으세요"라는 가이드 문구 추가.
    - 클립보드 붙여넣기 이벤트 리스너의 포커스 관리 로직 최적화.

### 2.3. 백엔드 연동 (Node.js API)
- `CreateTreeRequest` 페이로드에 각 이미지별 `hint` 값이 누락 없이 전달되는지 확인.
- DB의 `tree_images` 테이블에 해당 힌트가 정상적으로 저장되는지 검증.

## 3. 작업 단계 (Implementation Steps)

### Step 1: ViewModel 수정
- [ ] `tree_media_mixin.dart`에 `updateImageHint` 메서드 구현.
- [ ] `notifyListeners()`를 통해 UI 즉시 반영 보장.

### Step 2: 힌트 입력 UI 구현
- [ ] `add_tree_image_grid.dart` 수정하여 이미지별 텍스트 입력창 추가.
- [ ] 다크 모드 테마에 맞는 Sleek한 디자인 적용 (NeoTheme 사용).

### Step 3: Ctrl+V 기능 강화
- [ ] `add_tree_upload_box.dart`에 `RawKeyboardListener` 또는 Focus 기반 붙여넣기 핸들러 보완.
- [ ] 붙여넣기 성공/실패 시 사용자 알림(SnackBar) 표시.

### Step 4: 통합 테스트
- [ ] 가문비나무 데이터를 예시로 대표/잎/수피/꽃/열매 힌트 입력 및 이미지 업로드 테스트.
- [ ] DB 저장 결과 확인 (`tree_images` 테이블 `hint` 컬럼).

## 4. 기대 효과
- **데이터 품질 향상**: 스마트 태그별 정교한 힌트 제공으로 퀴즈 및 도감 서비스의 가치 상승.
- **작업 효율성 증대**: Ctrl+V 지원을 통해 외부 자료(구글 드라이브 등)로부터의 빠른 이미지 이식 가능.
