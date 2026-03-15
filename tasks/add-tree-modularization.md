# Task: AddTreeScreen 모듈화 및 리팩토링 계획서 (V2)

## 1. 개요
현재 1,092라인의 `add_tree_screen.dart`를 `DEVELOPMENT_RULES.md`의 핵심 원칙(MVVM 패턴, 파일당 200줄 제한, NeoStyle UI 준수)에 따라 전면 리팩토링하여 유지보수성과 성능을 극대화합니다.

## 2. DEVELOPMENT_RULES.md 준수 사항
- **[Rule 1-2] 코딩 가이드라인**: 모든 파일은 200줄 이하로 유지. (이미지 관리, 기본 정보 등 섹션별 분리 필수)
- **[Rule 2-1] 아키텍처 패턴**: MVVM 패턴을 강화하여 로직은 ViewModel로, UI는 Stateless 위젯으로 구성.
- **[Rule 2-2] 상태 관리**: `Provider` 및 `Selector`를 사용하여 렌더링 부하 최소화.
- **[Rule 3-1] UI/디자인**: `NeoTheme` 시스템 및 `ACID Lime` 색상 가이드 준수.
- **[Rule 3-3] 최신 API**: `withOpacity` 대신 `withValues(alpha: ...)` 사용.
- **[Rule 4-1] 빌드**: 작업 완료 후 `flutter analyze` 및 `flutter build apk` 정합성 검증 필수.

## 3. 세부 작업 단계 (Phases)

### **Phase 1: ViewModel 강화 및 비즈니스 로직 캡슐화**
- [x] `AddTreeViewModel`에 이미지 업로드 처리 로직(`dropzone`, `clipboard`, `picker`) 완전 이관.
- [x] UI 종속적인 `TextEditingController`들을 ViewModel에서 통합 관리하도록 구조 개선.
- [x] Web 전용 `DropZone` 등록 로직을 ViewModel 또는 전용 유틸리티로 분리.
- [x] **[Git Commit]**: `Phase 1: Refactor business logic into AddTreeViewModel and separate controller management`

### **Phase 2: 위젯 모듈화 (200줄 제한 준수)**
- [x] `AddTreeScreen`: 메인 파일은 150줄 이내의 Composition Root로 변경.
- [x] `AddTreeHeader`: 앱바 액션 및 저장/삭제 컨트롤 그룹화 분리 (widgets/add_parts/).
- [x] `AddTreeBasicInfoSection`: 이름, 학명, 카테고리 등 텍스트 기반 입력 섹션 독립.
- [x] `AddTreeImageManager`: 파일 업로드, 드래그&드롭, 이미지 그리드 렌더링 독립 위젯화.
- [x] `AddTreeQuizConfig`: 퀴즈 오답(Distractors) 리스트 관리 섹션 독립.
- [x] `AddTreeMobilePreview`: Drawer 내부의 프리미엄 모바일 시뮬레이터 UI 분리.
- [x] **[Git Commit]**: `Phase 2: Modularize UI components into independent widgets under 200 lines`

### **Phase 3: NeoTheme 스타일 고도화 및 품질 관리**
- [x] 모든 인라인 스타일을 `NeoTheme` 상수로 교체 및 `ACID Lime` 포인트 컬러 적용.
- [x] 모든 불투명도 지정을 최신 SDK API인 `withValues(alpha: ...)`로 교체.
- [x] 네트워크 장애 및 업로드 실패 상황을 위한 `ErrorState` 위젯 적용 및 재시도 로직 구현.
- [x] **[Git Commit]**: `Phase 3: Apply NeoTheme styling and implement robust error recovery UI`

### **Phase 4: 완결성 검증 및 빌드 테스트**
- [x] `flutter analyze` 실행하여 린트 오류 제로(Zero) 달성 확인.
- [x] `flutter build apk --debug`를 통한 최종 안드로이드 빌드 성공 확인.
- [x] 코드 리뷰를 통해 모든 리팩토링된 파일의 200라인 준수 여부 최종 점검.
- [x] **[Git Commit]**: `Final: AddTreeScreen refactoring verified with lint and build success`

## 4. 리팩토링 후 예상 폴더 구조
```text
lib/features/trees/
├── viewmodels/
│   └── add_tree_viewmodel.dart
└── screens/
    ├── add_tree_screen.dart (Composition Root)
    └── widgets/
        └── add_parts/
            ├── add_tree_header.dart
            ├── add_tree_basic_info_section.dart
            ├── add_tree_image_manager.dart
            ├── add_tree_quiz_config.dart
            └── add_tree_mobile_preview.dart
```
