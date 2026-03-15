# 📋 QuizScreen 리팩토링 및 모듈화 작업 계획서 (Refined by DEVELOPMENT_RULES.md)

`flutter_user_app`의 `quiz_screen.dart` 파일(현재 720라인)을 `DEVELOPMENT_RULES.md` 표준에 따라 200라인 이하의 모듈로 분리하고 성능 및 안정성을 강화하기 위한 계획입니다.

## 1. 목적 및 배경
- **[Rule 1-1] 200줄 제한 원칙**: 720라인의 단일 파일을 기능별 위젯으로 분리하여 가독성과 유지보수성 향상.
- **[Rule 0-3] 오류 사전 예방**: 복잡한 `setState` 구조를 `Provider` 기반으로 개선하여 UI 버그 및 성능 저하 방지.
- **[Rule 4-3] 플랫폼 독립성**: 모바일 환경에서 안정적인 동작을 위해 이미지 캐싱 및 오프라인 동기화 로직 강화.

## 2. 작업 원칙 (Standard Rules)
- **절대 경로 사용**: 모든 Import 및 파일 작업 시 `d:/MasterTreeApp/...` 절대 경로를 사용한다.
- **인코딩 준수**: 윈도우 환경 대응을 위해 명령어 실행 시 `chcp 65001`을 선행한다.
- **빌드 완결성**: 수정 후 `flutter analyze`를 통해 린트 에러를 0으로 유지하고 안드로이드 빌드 정합성을 확인한다.
- **Git 커밋**: 각 Phase 완료 시 로컬 Git 커밋을 반드시 수행한다.

## 3. 세부 작업 단계 (To-Do List)

### **Phase 1: 기반 구조 변경 및 로직 최적화**
- [ ] 현재 상태 백업 (`git add .`) - **[Rule 0-1]**
- [ ] `QuizController`를 `QuizViewModel` (`ChangeNotifier`)로 마이그레이션.
- [ ] `setState` 호출을 `notifyListeners()`로 대체하고 `Provider` 주입 구조 설계.
- [ ] **[Git Commit]**: `Phase 1: Refactor quiz logic to Provider-based ViewModel`

### **Phase 2: 위젯 모듈화 (Source Splitting - Rule 1-1)**
- [ ] `quiz_screen.dart`: 100줄 이내의 Composition Root로 리팩토링.
- [ ] `QuizHeader`: 프로그레스 바 및 상단 컨트롤 분리. (`widgets/quiz_parts/`)
- [ ] `QuizImageDisplay`: 이미지 렌더링 및 확대/축소 로직 분리. (Max 200 lines)
- [ ] `QuizHintToolbar`: 힌트 아이콘 및 선택 상태 UI 독립.
- [ ] `QuizOptionsList`: 4지선다형 정답 선택지 리스트 분리.
- [ ] `QuizOverlayManager`: 힌트/정답 설명 레이어(Stack) 분리 및 최적화.
- [ ] **[Git Commit]**: `Phase 2: Modularize QuizScreen into sub-widgets under 200 lines`

### **Phase 3: 성능 최적화 및 안정화 (Rule 3-2, 4-3)**
- [ ] `CachedNetworkImage` 도입 및 이미지 로딩 에러 핸들링 강화.
- [ ] `Selector`를 사용하여 힌트 메시지 팝업 시 불필요한 위젯 리빌드 방지.
- [ ] 네트워크 장애 시 학습 결과 유실 방지를 위한 로컬 저장/재시도 큐 보강.
- [ ] **[Git Commit]**: `Phase 3: Optimize performance and add network resilience`

### **Phase 4: 완결성 검증 (Rule 2-3, 3-2)**
- [ ] `flutter analyze` 명령어로 모든 린트 및 스타일 가이드 준수 확인.
- [ ] 파일별 라인 수 최종 체크 (모두 200줄 이하인지 확인).
- [ ] `flutter build apk --debug`를 통해 안드로이드 컴파일 및 인프라 정합성 확인.
- [ ] **[Git Commit]**: `Final: QuizScreen modularization complete and verified`

## 4. 예상 폴더 구조
```text
lib/
├── controllers/
│   └── quiz_viewmodel.dart
└── screens/
    ├── quiz_screen.dart (Composition Root)
    └── widgets/
        └── quiz_parts/
            ├── quiz_header.dart
            ├── quiz_image_display.dart
            ├── quiz_hint_toolbar.dart
            ├── quiz_options_list.dart
            └── quiz_overlay_manager.dart
```

---
**주의:** 모든 작업은 위 계획에 따라 순차적으로 진행하며, 개발자님의 승인 후에 구현을 시작합니다.
