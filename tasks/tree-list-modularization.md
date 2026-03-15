# 📋 TreeListScreen 리팩토링 및 모듈화 작업 계획서

`tree_list_screen.dart` 파일의 가독성, 유지보수성, 성능을 향상시키기 위해 `DEVELOPMENT_RULES.md` 가이드라인에 따라 소스 분리 및 리팩토링을 수행합니다.

## 1. 목적
- 현재 **630라인**의 단일 파일을 **200줄 이하**의 여러 모듈로 분리.
- **MVVM 패턴**을 강화하여 비즈니스 로직과 UI 코드의 의존성 최소화.
- **NeoTheme** 적용을 통한 프리미엄 관리자 UI 일관성 확보.
- **성능 최적화**: 리스트 렌더링 부하 분산 및 불필요한 리빌드 방지.

## 2. 작업 원칙
- 모든 파일은 **200라인 이내**로 유지.
- `withOpacity` 대신 최신 API인 `withValues(alpha: ...)` 사용.
- `WebUtils`를 사용하여 Web 관련 로직(CSV 다운로드 등) 격리.
- 단계별 **로컬 Git 커밋** 수행.
- 수정 전/후 **린트 에러(`flutter analyze`)** 및 **안드로이드 빌드** 확인.

## 3. 세부 작업 단계 (Phases)

### **Phase 1: ViewModel 및 데이터 레이어 강화**
- [x] `TreeListViewModel`에서 검색, 필터링 로직 안정화 및 에러 핸들링 추가.
- [x] CSV Export/Import 로직의 예외 처리 강화 및 `WebUtils` 활용 확인.
- [x] **[Git Commit]**: `Phase 1: Enhance TreeListViewModel logic and error handling`

### **Phase 2: 위젯 모듈화 (Source Splitting)**
- [x] `TreeListScreen`: 메인 파일은 100줄 이내의 Composition Root로 변경.
- [x] `TreeListHeader`: 앱바, 타이틀, CSV 메뉴 분리. (`widgets/list_parts/`)
- [x] `TreeListSearchBar`: 검색창 입력 로직 및 UI 분리.
- [x] `TreeListCategoryFilters`: 카테고리 칩 필터 섹션 독립.
- [x] `TreeListStatsBar`: 총 건수 및 페이지네이션 컨트롤러 분리.
- [x] `TreeListItem`: 개별 수목 리스트 아이템 위젯화 및 성능 최적화.
- [x] `TreeListDeleteDialog`: 삭제 확인 팝업 분리.
- [x] **[Git Commit]**: `Phase 2: Modularize TreeListScreen into independent widgets under 200 lines`

### **Phase 3: NeoTheme 스타일 고도화 및 UX 개선**
- [x] 인라인 컬러 및 스타일을 `NeoTheme` 상수로 교체.
- [x] `primaryColor`를 `NeoColors.acidLime` 등으로 일원화 및 디자인 디테일 향상.
- [x] 네트워크 장애 시 재시도를 위한 `NeoErrorState` 위젯 적용.
- [x] **[Git Commit]**: `Phase 3: Apply NeoTheme styling and implement error recovery UI`

### **Phase 4: 완결성 검증 및 빌드 테스트**
- [ ] `flutter analyze` 실행하여 모든 린트 및 경고 사항 해결.
- [ ] `flutter build apk --debug`를 통한 안드로이드 정합성 확인.
- [ ] 최종 코드 리뷰: 모든 파일의 200줄 이하 유지 확인.
- [ ] **[Git Commit]**: `Final: TreeListScreen refactoring complete and verified`

## 4. 리팩토링 후 예상 폴더 구조
```text
lib/features/trees/
├── viewmodels/
│   └── tree_list_viewmodel.dart
└── screens/
    ├── tree_list_screen.dart
    └── widgets/
        └── list_parts/
            ├── tree_list_header.dart
            ├── tree_list_search_bar.dart
            ├── tree_list_category_filters.dart
            ├── tree_list_stats_bar.dart
            └── tree_list_item.dart (및 관련 다이얼로그)
```

---
**진행 가이드:** 위 작업 계획에 따라 각 Phase가 완료될 때마다 개발자님의 승인을 받거나 다음 단계로 진행합니다.
