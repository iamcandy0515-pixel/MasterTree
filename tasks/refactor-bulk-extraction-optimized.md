# 🧩 작업 계획서: `bulk_extraction_screen.dart` 최적화 및 처리 엔진 분리 (Processing Engine Split)

## 1. 개요 (Objective)
-   **대상**: `flutter_admin_app/lib/features/quiz_management/screens/bulk_extraction_screen.dart`
-   **목표**: PDF 청킹 및 추출 비즈니스 로직과 복잡한 에디터 UI를 물리적으로 분리하여 로드 부하를 줄이고 200줄 제한을 준수함.
-   **준수 규칙**: 200줄 제한(1-1), 비즈니스 로직 캡슐화(2-1), 모바일 렌더링 최적화(3-2).

## 2. 분석 및 개선 전략 (Strategy)
### 🚨 현 상태 분석
- 추출 컨트롤러(`ViewModel`)가 있음에도 불구하고, 화면 파일 내부에 탭 스크롤링, 에디터 필드 동기화, 필터 유지 등 복합적인 로직이 밀결합되어 있음.
- 현재 203라인으로 프로젝트 표준인 200줄을 초과하고 있어 즉각적인 분할이 필요함.

### ✨ 개선 핵심 (The Better Proposal)
1.  **Extraction Process Engine Separation**: PDF 텍스트 청킹 및 서버 통신 조율 로직을 전용 `ExtractionHandler` 서비스로 분리하여 앱의 응답성 확보.
2.  **Sectional Editor Implementation**: 에디터 본문을 독립적인 섹션 위젯으로 분리(`parts/bulk_editor_view.dart`)하여 필드 수정 시 불필요한 레이아웃 재연산 방지.
3.  **Virtualized Result Rendering**: 추출 결과 리스트를 `ListView.builder` 또는 `SliverList`로 개편하여 대량 문항 처리 시의 메모리 스파이크 억제.

## 3. To-Do List 및 단계별 실천 계획

### Phase 1: 사전 준비 및 기저 작업
- [ ] **[Git]** 현재 소스 로컬 커밋 수행 (`pre-opt-bulk-extraction`)
- [ ] **[Check]** `BulkExtractionViewModel`과의 데이터 바인딩 구조 재점검

### Phase 2: 소스 분할 및 레이어화 (Source Splitting)
- [ ] **[Extract]** `parts/bulk_tab_navigation.dart` 분리 (청크 선택 및 스크롤 로직)
- [ ] **[Extract]** `parts/bulk_editor_view.dart` 분리 (문제 수정을 위한 독립 위젯 레이어)
- [ ] **[Transfer]** 필터 동기화 및 텍스트 파싱 헬퍼를 전용 `Handler/Service`로 이관

### Phase 3: 완결성 확인 및 빌드 (Rule 2-3)
- [ ] **[Lint]** `flutter analyze` 실행 및 린트 오류 제로화
- [ ] **[Build]** 실제 관리자 앱 빌드 후 대용량 PDF 추출 안정성 테스트
- [ ] **[Git]** 최종 성과 커밋 및 보고 (`opt-bulk-extraction-complete`)

---

> [!IMPORTANT]
> **위 계획서를 검토해 주시고, 승인을 해주시면 즉시 구현 절차에 착수하겠습니다.**
