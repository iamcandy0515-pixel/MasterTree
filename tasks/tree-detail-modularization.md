# Task: 수목 상세 화면 (TreeDetailScreen) 리팩토링 및 모듈화 계획

본 계획서는 `DEVELOPMENT_RULES.md` 가이드라인을 엄격히 준수하여 `tree_detail_screen.dart`의 구조적 결함을 해결하고, 모바일 환경에 최적화된 마스터 데이터 관리 화면으로 전환하기 위한 단계별 전략입니다.

## 1. 목적 및 목표 (Compliance)
- **Rule 1-1 (경량화)**: 470줄의 파일을 200줄 이내로 분리하여 코드 가독성 및 유지보수성 극대화.
- **Rule 1-2 (MVVM)**: `Provider`와 `Selector`를 도입하여 비즈니스 로직을 `ViewModel`로 캡슐화하고 최적의 리빌드 성능 확보.
- **Rule 1-3 (모듈화)**: 재사용 가능한 위젯 구조로 분할하여 UI 의존성 최소화.
- **Rule 0-3 (디자인)**: `NeoTheme` 스타일 시스템과 최신 `withValues` API를 전면 적용하여 프리미엄 UI 구현.

## 2. 세부 작업 단계 (Phases)

### **Phase 1: ViewModel 기반 구조 설계 및 데이터 로직 분리**
- [x] `TreeDetailViewModel.dart` 생성 (`ChangeNotifier` 기반).
- [x] `TextEditingController` 통합 관리 및 `Tree` 객체와의 매핑 로직 구현.
- [x] 서버 통신 로직(`saveHints`)을 ViewModel로 이전하여 캡슐화.
- [x] `tree_detail_screen.dart`를 `StatelessWidget`으로 변경 및 `Provider` 연동.
- [x] **[Git Commit]**: "Phase 1: Implement TreeDetailViewModel and refactor state management"

### **Phase 2: 위젯 모듈화 및 200줄 최적화**
- [x] `TreeDetailHeader`: 앱바 및 제목 영역 분리.
- [x] `TreeBasicInfoSection`: 수목 설명 및 카테고리 태그 영역 추출.
- [x] `TreeHintSection`: 5개 부위별 힌트 입력 필드 그룹화 및 추출.
- [x] `TreePreviewDialog`: 미리보기 기능을 별도의 위젯 파일로 독립.
- [x] 메인 파일(`tree_detail_screen.dart`)을 150줄 이내로 경량화.
- [x] **[Git Commit]**: "Phase 2: Extract modular widgets for TreeDetailScreen and optimize file size"

### **Phase 3: 디자인 스타일 고도화 및 품질 관리**
- [x] `NeoTheme` ACID Lime 스타일 및 프리미엄 그림자/그라데이션 효과 적용.
- [x] 모든 `withOpacity` 코드를 `withValues(alpha: ...)` 최신 SDK API로 교체.
- [x] 네트워크 장애 시 재시도 로직 및 `ErrorState` 위젯 적용.
- [x] **[Git Commit]**: "Phase 3: Apply NeoTheme styling and implement error handling stability"

### **Phase 4: 완결성 검증 및 빌드 테스트**
- [x] `flutter analyze` 실행 (린트 오류 Zero 준수).
- [x] `flutter build apk`를 실행하여 안드로이드 빌드 정합성 확인 (Rule 4-1).
- [x] 최종 코드 리뷰를 통해 200줄 제한 및 클린 코드 준수 여부 확인.
- [x] **[Git Commit]**: "Final: Refactoring complete and quality assurance verified"

## 3. 리팩토링 후 폴더 구조
```text
lib/features/trees/
├── screens/
│   ├── tree_detail_screen.dart (경량화 완료)
│   └── widgets/
│       └── detail_parts/
│           ├── tree_detail_header.dart
│           ├── tree_basic_info_section.dart
│           ├── tree_hint_section.dart
│           └── tree_preview_dialog.dart
└── viewmodels/
    └── tree_detail_viewmodel.dart
```

---
**보고**: 본 작업 계획서는 `DEVELOPMENT_RULES.md`를 모두 반영하였으며, **개발자님의 최종 승인 없이는 어떠한 코드 수정도 진행하지 않습니다.**
