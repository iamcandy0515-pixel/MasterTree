# [작업 계획서] 'TreeDetailSheet' 모바일 성능 최적화 및 구조 리팩토링

본 계획서는 `DEVELOPMENT_RULES.md`와 `FLUTTER_3_7_12_TECH_SPEC.md`를 엄격히 준수하여 모바일 환경의 로드 부하를 최소화하고 유지보수성을 극대화하기 위해 작성되었습니다.

## 1. 분석 및 과제 현황
- **현재 파일**: `lib/screens/tree_list/widgets/tree_detail_sheet.dart` (약 292라인)
- **위반 사항**: 200라인 초과 원칙 위반.
- **주요 부하 요소**:
  - 단일 파일 내 고해상도 이미지 처리 로직과 UI 분기 로직 혼재.
  - 범용적인 `CircularProgressIndicator` 사용으로 인한 UI 품질 저하.
  - 네트워크 이미지를 매번 새로 로드하여 사용자 데이터 및 배터리 소모 유발.

## 2. 세부 작업 단계 (Phased Plan)

### Phase 1: 위젯 독립화 및 가독성 향상 (Modularity)
- **추출 대상 위젯 (`lib/screens/tree_list/widgets/detail/` 하위 생성)**:
  - `TreePartSelector.dart`: 5개의 수목 파트(대표, 잎 등) 선택 탭 UI.
  - `TreeHeroSection.dart`: 이미지 렌더링, 그라데이션, 이름/학명 레이아웃 전담.
  - `TreeAttributeRow.dart`: '구분', '수형' 등 리스트 형태의 속성 정보 개별 위젯.
- **목표**: `TreeDetailSheet.dart`의 라인 수를 100라인 이내로 축소.

### Phase 2: 모바일 성능 및 리소스 최적화 (Optimization)
- **이미지 핸들링**: `CachedNetworkImage`를 적용하여 로컬 캐시 활용.
- **이미지 사전 로딩 (Pre-fetching)**: `precacheImage` API를 활용하여 탭 전환 시 지연 시간 제로(Zero)화.
- **메모리 최적화**: 디바이스 해상도 기반 `memCacheWidth` 설정으로 램 점유율 최소화.
- **검증**: `flutter analyze` 후 스타일/문법 오류 체크 및 `linter` 활용.

### Phase 3: UX 감품 고도화 (Premium UX)
- **스켈레톤 로딩 (Skeleton Loading)**: `shimmer`를 적용한 `TreeDetailSkeleton` 구현.
- **애니메이션**: `AnimatedSwitcher`를 활용한 파트 전환 페이드 효과 적용.
- **학명 전용 스타일**: 식물학 교육용 특화 폰트 스타일(이탤릭 등) 세부 정돈.

## 3. Git 커밋 전략 (Commit Strategy)
- **Commit 1**: `docs(tree_list): add refactoring task plan for tree_detail_sheet optimization`
- **Commit 2**: `refactor(tree_list): modularize tree detail components into separate widgets`
- **Commit 3**: `perf(tree_list): implement image caching and pre-fetching for tree detail`
- **Commit 4**: `feat(tree_list): add high-end skeleton loading using shimmer`

## 4. 수행 규칙 체크리스트
- [x] 파일당 200라인 이하 준수 여부
- [x] Flutter 3.7.12 / Dart 2.19.6 호환성 확인
- [x] `const` 생성자 및 `StatelessWidget` 우선 사용
- [x] `linter` 스타일 체크 수행

---
**개발자님의 승인 후 작업을 시작하겠습니다.**
