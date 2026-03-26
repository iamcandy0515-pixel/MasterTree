# 작업 계획서: 신규수목등록 힌트 입력 및 이미지 붙여넣기 고도화 (admin-add-tree-hint-paste)

## 1. 개요 (Analysis & Planning)

### 1.1. 현상 분석
- 현재 도감 데이터의 핵심인 '스마트 태그별 힌트(잎, 수피, 꽃, 열매 등)'를 관리자 앱에서 직접 입력할 수 있는 필드가 부족함.
- 이미지 등록 시 Ctrl+V(붙여넣기) 기능이 구현되어 있으나, 가이드가 부족하여 사용자가 인지하기 어려움.
- `tree_images` 테이블의 `hint` 컬럼에 데이터를 정상적으로 매핑하기 위한 로직 보강이 필요함.

### 1.2. 작업 전략 (Strategy)
- **개발 규칙(Rule 1-1, 1-2) 준수**: 단일 파일 200줄 제한을 지키기 위해 힌트 입력 전용 위젯(`AddTreeImageHintField`)을 분리함.
- **이미지-힌트 1:1 매핑**: 업로드된 이미지 리스트의 각 아이템에 힌트 입력 기능을 통합함.
- **사용자 경험(UX) 강화**: 붙여넣기 기능 활성화 조건(Focus 등)을 명확히 하고 UI 가이드를 추가함.

## 2. 세부 작업 내용 (Implementation Details)

### 2.1. 모델 및 ViewModel 보강
- `TreeMediaMixin`: `updateImageHint(int index, String hint)` 메서드 추가.
- `CreateTreeRequest`: 각 이미지 객체의 `hint` 필드가 백엔드로 정확히 전달되는지 재점검.

### 2.2. UI 컴포넌트 분리 및 고도화
- **신규 파일 생성**: `flutter_admin_app/lib/features/trees/screens/widgets/add_parts/add_tree_image_hint_input.dart`
    - 이미지 클릭 시 또는 하단에 노출되는 소형 텍스트 입력 위젯. (200줄 분리 원칙 준수)
- **기존 파일 수정**: 
    - `add_tree_image_grid.dart`: `AddTreeImageHintInput`을 그리드 아이템에 통합.
    - `add_tree_upload_box.dart`: Ctrl+V 가이드 텍스트 색상 및 아이콘 강조(`NeoColors.acidLime` 활용).

### 2.3. 사전 리스크 체크
- **UI Overflow**: 그리드 내 텍스트 필드 추가 시 공간 부족 문제 -> 모달 또는 확장형 패널 검토.
- **Focus 이슈**: Ctrl+V가 작동하려면 특정 FocusNode가 활성화되어야 함. 업로드 박스 클릭 시 Focus를 강제하도록 로직 개선.

## 3. To-Do List

### 3.1. 준비 단계
- [ ] 현재 작업 상태 로컬 Git 커밋 (`git add . && git commit -m "Plan: Add tree hint & paste enhancement"`)
- [ ] 터미널 인코딩 확인 (`chcp 65001`)

### 3.2. 구현 단계
- [ ] `TreeMediaMixin` 메서드 추가 및 테스트.
- [ ] `AddTreeImageHintInput` 위젯 신규 생성 (Modularization).
- [ ] `AddTreeImageGrid` 레이아웃 수정 및 연동.
- [ ] `AddTreeUploadBox` 가이드 디자인 개선 및 Focus 로직 보정.

### 3.3. 검증 단계
- [ ] `flutter analyze`를 통한 린트 에러 체크.
- [ ] 가문비나무 상세 힌트 입력 테스트 및 DB 저장 확인.

## 4. 최종 확인 및 유실 방지
- [ ] 수정 외 코드 삭제 여부 확인 (Diff 분석).
- [ ] 200줄 초과 파일 유무 재검토.
