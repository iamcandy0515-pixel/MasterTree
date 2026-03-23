# 🧩 작업 계획서: Unified Extraction Header 모듈화 및 UI 분리 (Rev. 2)

이 문서는 `unified_extraction_header.dart`의 200라인 초과 이슈를 해결하고, 검색/필터/액션 영역을 독립된 전문 위젯으로 분리하여 `DEVELOPMENT_RULES.md`를 준수하며 유지보수성을 극대화하기 위한 상세 계획입니다.

## 1. 분석 및 문제 정의 (Analysis)
### 1.1 현상 파악 (Current State)
- **파일 경로**: `lib/features/quiz_management/screens/widgets/quiz_extraction/unified_extraction_header.dart`
- **파일 크기**: **330라인** (규칙 1-1. 200줄 제한 위반)
- **주요 병목**:
    - 드라이브 검색, 필터 선택, 추출 액션 로직이 한 파일에 밀집됨.
    - `_floatingMessage`와 타이머 기반 `setState` 로직이 UI 코드와 섞여 가독성 저하.
    - 3개의 드롭다운(과목, 연도, 회차)의 UI 스타일링 코드가 중복됨.

### 1.2 확정된 전략 (Selected Strategy)
1. **3개 전문 위젯 분리 (Row-based Separation)**: 검색창, 필터 패널, 액션 박스를 각각 독립된 위젯으로 분리하여 단일 책임을 부여함.
2. **독립 상태 알림 위젯 캡슐화 (Status Encapsulation)**: `setState` 타이머를 내포한 `ExtractionStatusOverlay`를 모듈화하여 메인 헤더를 순수 UI 조합 창으로 구성함.
3. **공통 `ExtractionDropdown` 개발 (Component Reuse)**: 중복된 드롭다운 UI 스타일을 한데 모은 범용 컴포넌트를 개발하여 코드량을 획기적으로 줄임.

---

## 2. 상세 작업 단계 (Execution Phases)

### Phase 1: 공통 컴포넌트 및 하위 위젯 구축
- **1-1. [0-1. Git 백업]** 작업 시작 전 현재 상태 커밋.
- **1-2. 범용 드롭다운 위젯 생성**: `extraction_dropdown.dart` 생성 (디자인 통일 및 중복 제거).
- **1-3. 상태 알림 위젯 생성**: `extraction_status_overlay.dart` 생성 (애니메이션 및 가림 로직 캡슐화).
- **1-4. 기능별Row 위젯 생성**:
    - `extraction_search_input.dart`: 구글 드라이브 검색 영역.
    - `extraction_filter_row.dart`: 공통 드롭다운을 활용한 필터 선택 영역.
    - `extraction_action_control.dart`: 문제 번호 선택 및 추출 실행 버튼 영역.

### Phase 2: 메인 헤더 구조 재설계 (Slimming)
- **2-1. UnifiedExtractionHeader 정돈**: 기존 330라인의 로직을 제거하고, 상기 생성된 3개 모듈을 `Column`으로 배치하여 라인수를 100라인 이하로 축소 (규칙 1-1 엄수).
- **2-2. ViewModel 연동 최적화**: 각 하위 위젯이 필요한 데이터와 콜백만 `Provider`를 통해 전달받거나 호출하도록 정합성 확보.

### Phase 3: 최종 검증 및 마무리
- **3-1. [1-3. 분리 후 동작 체크]** 검색, 필터 변경, 추출 실행 및 알림 정상 동작 확인.
- **3-2. [3-2. 린트 체크]** `flutter analyze` 명령어로 품질 검증.
- **3-3. [0-4. 소스 정합성]** `git diff` 분석을 통한 미사용 코드 유실 체크.
- **3-4. [0-2. Git 최종 커밋]** 완료 상태 커밋.

---

## 3. To-Do List (Checklist)

### 구현 전 (Pre-Implementation)
- [ ] **[0-1. Git 백업]** 현재 상태 커밋 (`git commit -m "pre-refactor: backup unified_extraction_header"`)
- [ ] `ExtractionDropdown`의 디자인 가이드(디자인 토큰) 정의

### 구현 중 (Implementation)
- [ ] `extraction_dropdown.dart` (범용 컴포넌트) 개발
- [ ] `extraction_status_overlay.dart` (상태 알림) 개발
- [ ] `extraction_search_input.dart` 분리
- [ ] `extraction_filter_row.dart` 분리
- [ ] `extraction_action_control.dart` 분리
- [ ] `unified_extraction_header.dart` 리팩토링 및 슬림화

### 구현 후 (Post-Implementation)
- [ ] **[1-1. 200라인 확인]** 모든 분리된 파일이 200라인 이하인지 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 수행 및 이슈 해결
- [ ] **[0-4. 소스 정합성]** 최종 소스 diff 확인 및 유실 방지 체크
- [ ] **[0-2. Git 최종 커밋]** 작업 결과 커밋

---

## 4. 기대 효과 (Expected Outcomes)
- **코드 효율성**: 중복 UI 코드 제거로 전체 코드량이 50% 이상 감소하며 가독성 대폭 향상.
- **안전성**: 상태 알림 타이머 등 부수 효과(Side-effect)가 제거되어 디버깅이 쉬워짐.
- **재사용성**: `ExtractionDropdown` 및 `FilterRow`를 향후 다른 문제 관리 화면에서도 즉시 사용 가능.
