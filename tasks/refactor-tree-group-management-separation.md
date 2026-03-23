# 🧩 작업 계획서: Tree Group Management Screen 리팩토링 및 성능 최격화

이 문서는 `tree_group_management_screen.dart`의 200라인 초과 이슈를 해결하고, 서버 기반 검색 및 삭제 로직을 강화하여 모바일 관리자 앱의 성능을 최적화하기 위한 상세 계획을 담고 있습니다.

## 1. 분석 및 문제 정의 (Analysis)
### 1.1 현상 파악 (Current State)
- **파일 경로**: `lib/features/trees/screens/tree_group_management_screen.dart`
- **파일 크기**: **450라인** (규칙 1-1. 200줄 제한 위반)
- **주요 문제**:
    - 단일 파일 내에 헤더, 검색, 리스트, 아이템, 로딩 로직이 혼재되어 유지보수 어려움.
    - 리스트 아이템에서 `NetworkImage`를 사용 중이라 스크롤 시 프레임 드랍 발생 가능.
    - 검색 기능이 UI만 있고 ViewModel 연동이 미비함.

### 1.2 확정된 전략 (Selected Strategy)
1. **서버 사이드 API 호출**: 검색어 입력 시 Debounce(300~500ms)를 적용하여 서버 API에 직접 쿼리함.
2. **Stack 썸네일**: 기존의 수목 썸네일 겹침 디자인을 유지하되, `CachedNetworkImage`로 성능 보완.
3. **즉시 삭제**: 리스트 아이템 롱클릭 시 삭제 확인 다이얼로그를 띄워 즉시 관리 가능하게 구현.
4. **모듈 분리**: 모든 소스 파일을 200라인 이하로 분리 (규칙 1-1).

---

## 2. 상세 작업 단계 (Execution Phases)

### Phase 1: 사전 준비 및 위젯 분리 (Modularization)
- **1-1. [0-1. Git 백업]** 현재 상태 로컬 Git 커밋.
- **1-2. 위젯 디렉토리 생성**: `lib/features/trees/screens/widgets/management/`
- **1-3. 모듈별 파일 생성 및 추출**:
    - `management_header_section.dart`: 검색 바 포함 헤더 추출.
    - `management_control_bar.dart`: 페이지네이션 및 그룹 추가 바 추출.
    - `tree_group_list_item.dart`: 개별 리스트 아이템 및 썸네일 스택 추출.
    - `management_shimmer_loader.dart`: 로딩용 Shimmer UI 추출.

### Phase 2: 기능 강화 및 성능 최적화
- **2-1. ViewModel 업데이트**:
    - `searchGroups(String query)` 추가 및 Debounce 로직 구현.
    - `deleteGroup(String id)` 기능을 `TreeGroupRepository`와 연결.
- **2-2. 리스트 아이템 고도화**:
    - `NetworkImage` -> `CachedNetworkImage` 교체.
    - 롱클릭 시 삭제 확인 다이얼로그 연동.
- **2-3. 메인 화면 슬림화**: `tree_group_management_screen.dart`를 추출된 위젯 조합으로 재구성 (150라인 이하).

### Phase 3: 최종 검증 및 테스트
- **3-1. [1-3. 분리 후 에러 체크]** Import 미스 및 UI Overflow 여부 확인.
- **3-2. [3-2. 린트 체크]** `flutter analyze`를 통한 코드 품질 검증.
- **3-3. [0-4. 소스 정합성]** `git diff` 분석으로 유실 여부 최종 체크.
- **3-4. [0-2. Git 최종 커밋]** 완료 상태 커밋.

---

## 3. To-Do List (Checklist)

### 구현 전 (Pre-Implementation)
- [ ] **[0-1. Git 백업]** 현재 상태 커밋 (`git commit -m "pre-refactor: backup tree_group_management_screen"`)
- [ ] `TreeGroupRepository`에 검색(query) 매개변수 지원 여부 최종 확인

### 구현 중 (Implementation)
- [ ] `TreeGroupManagementViewModel` 검색 및 삭제 로직 보강
- [ ] `./widgets/management/management_header_section.dart` 분리
- [ ] `./widgets/management/management_control_bar.dart` 분리
- [ ] `./widgets/management/tree_group_list_item.dart` 분리 (`CachedNetworkImage` 및 롱클릭 적용)
- [ ] `./widgets/management/management_shimmer_loader.dart` 분리
- [ ] `tree_group_management_screen.dart` 메인 파일 슬림화 (200라인 이하 달성)

### 구현 후 (Post-Implementation)
- [ ] **[1-3. 분리 후 에러 체크]** 화면 전환 및 데이터 로드 정상 여부 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 수행 및 이슈 해결
- [ ] **[0-4. 소스 정합성]** 최종 소스 diff 확인 및 유실 방지 체크
- [ ] **[0-2. Git 최종 커밋]** 작업 결과 커밋

---

## 4. 기대 효과 (Expected Outcomes)
- **가독성**: 450라인 -> 100라인 내외로 축소되어 로직 파악이 용이함.
- **성능**: 이미지 캐싱 및 지연 로딩을 통해 리스트 스크롤이 매우 부드러워짐.
- **사용성**: 리스트에서 바로 검색하고 삭제할 수 있어 관리 업무 효율성 증대.
