# 🧩 작업 계획서: Tree Lookalike Detail Screen 리팩토링 및 성능 최적화

이 문서는 `tree_lookalike_detail_screen.dart`의 200라인 초과 이슈를 해결하고, 모바일 환경의 스크롤 성능을 최적화하기 위한 상세 계획을 담고 있습니다.

## 1. 분석 및 문제 정의 (Analysis)
### 1.1 현상 파악 (Current State)
- **파일 경로**: `lib/features/trees/screens/tree_lookalike_detail_screen.dart`
- **파일 크기**: **496라인** (규칙 1-1. 200줄 제한 위반)
- **주요 병목**:
    - `_ComparisonMatrix` 위젯이 전체 코드의 70% 이상을 차지하며 스크롤 로직과 UI 렌더링을 혼재해서 담당함.
    - 모든 수목 데이터를 `Row` 내부에서 한꺼번에 생성하여 메모리 및 렌더링 부하 발생 가능.

### 1.2 리팩토링 목표
- **규칙 준수**: 모든 소스 파일을 200라인 이하로 분리 (규칙 1-1).
- **성능 개선**: 가로 스크롤 섹션에 지연 로딩(Lazy Loading) 적용.
- **안정성 확보**: 분리 후 Import 에러 및 UI Overflow 방지 (규칙 1-3).

---

## 2. 전략적 질문 (Socratic Gate)
*작업 시작 전 아래 사항에 대해 개발자님의 확인이 필요합니다.*
1. **디자인 유지**: `ListView.builder` 적용 시 가로 스크롤 위치에 따른 고정 라벨(이미지, 수목명 등)과의 정렬 유지가 중요합니다. 기존 디자인 레이아웃을 엄격히 유지해야 합니까?
2. **최대 데이터 수**: 한 그룹당 최대 몇 그루의 나무가 비교 대상이 될 수 있습니까? (성능 최적화 강도 조절용)
3. **추가 기능**: 리팩토링 과정에서 이미지 클릭 시 전체 화면 보기 기능을 추가할까요?

---

## 3. 상세 작업 단계 (Execution Phases)

### Phase 1: 사전 준비 및 위젯 분리 (Modularization)
- **1-1. [0-1. Git 백업]** 현재 상태를 로컬 Git에 커밋.
- **1-2. 위젯 파일 생성**: `lib/features/trees/screens/widgets/lookalike/` 경로에 아래 파일 생성.
    - `lookalike_tab_selector.dart`: 탭 전환(잎/수피) 모듈.
    - `lookalike_tree_column.dart`: 개별 나무 데이터 및 이미지 렌더링 위젯.
    - `lookalike_nav_controls.dart`: 스크롤 제어 버튼 모듈.
- **1-3. 매트릭스 모듈화**: `lookalike_comparison_matrix.dart` 생성 및 가로/세로 복합 스크롤 로직 이관.

### Phase 2: 성능 최적화 및 메인 화면 재구현
- **2-1. 지연 로딩 구현**: `Row` 기반의 멤버 렌더링을 `ListView.builder`로 전환.
- **2-2. 메인 화면 슬림화**: `tree_lookalike_detail_screen.dart`에서 추출된 모듈을 조립하여 200라인 이하로 재구성.
- **2-3. UI 정합성 체크**: 고정 헤더와 스크롤 데이터 간의 높이/너비 일치 여부 및 Overflow 에러 확인 (규칙 1-3).

### Phase 3: 최종 검증 및 테스트
- **3-1. [3-2. 린트 체크]** `flutter analyze` 실행하여 모든 경고 제거.
- **3-2. [0-4. 소스 정합성]** `git diff` 분석을 통해 의도치 않은 코드 누락 및 유실 체크.
- **3-3. [0-2. Git 최종 커밋]** 리팩토링 완료 상태 커밋.

---

## 4. To-Do List (Checklist)

### 구현 전 (Pre-Implementation)
- [ ] **[0-1. Git 백업]** 현재 상태 커밋 (`git commit -m "pre-refactor: backup tree_lookalike_detail_screen"`)
- [ ] Socratic Gate 질문에 대한 답변 확인 및 전략 확정

### 구현 중 (Implementation)
- [ ] `./widgets/lookalike/lookalike_tab_selector.dart` 분리
- [ ] `./widgets/lookalike/lookalike_tree_column.dart` 분리 (이미지 최적화 포함)
- [ ] `./widgets/lookalike/lookalike_nav_controls.dart` 분리
- [ ] `./widgets/lookalike/lookalike_comparison_matrix.dart` 분리 및 `ListView.builder` 적용
- [ ] `tree_lookalike_detail_screen.dart` 메인 파일 슬림화 (200라인 이하 달성)

### 구현 후 (Post-Implementation)
- [ ] **[1-3. 분리 후 에러 체크]** Import 경로 및 UI 크래시 여부 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 수행 및 이슈 해결
- [ ] **[0-4. 소스 정합성]** 최종 소스 diff 확인 및 유실 방지 체크
- [ ] **[0-2. Git 최종 커밋]** 완료 커밋

---

## 5. 기대 효과 (Expected Outcomes)
- **가독성**: 496라인 -> 100라인 내외로 축소되어 유지보수 편의성 증대.
- **성능**: 대량 데이터 로드 시에도 부드러운 스크롤과 낮은 메모리 사용량 보장.
- **안정성**: `DEVELOPMENT_RULES.md`를 철저히 준수하여 빌드 및 런타임 안정성 확보.
