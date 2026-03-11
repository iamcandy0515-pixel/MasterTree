# Task: Tree Detail Screen Full Restoration & Hint Integration (v1)

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 분석

- **현상:** 현재 '수목일람 상세화면(`TreeDetailScreen`)'은 수목 설명과 부위별 힌트 수정에만 집중되어 있음.
- **요구사항:** 기존에 존재했던(또는 `AddTreeScreen` 수준의) 모든 수목 필드(이름, 학명, 분류, 난이도, 퀴즈 오답 등)를 편집할 수 있도록 **복구**하고, 최근 추가된 **부위별 힌트** 관리 기능과 통합.
- **참조:** `AddTreeScreen`의 전체 입력 폼과 `TreeDetailScreen`의 힌트/미리보기 기능 융합.

## 2. PLANNING (작업 단계별 계획)

### 1단계: ViewModel 분석 및 통합 (`add_tree_viewmodel.dart` 참조)

- `AddTreeViewModel`은 이미 전체 필드 수정을 지원함.
- `TreeDetailScreen`에서는 현재 `TreeRepository().updateTree()`를 직접 호출하고 있음.
- 안정적인 복구를 위해 `AddTreeScreen`의 디자인 패턴(섹션 구분, 폼 필드)을 `TreeDetailScreen`에 이식.

### 2단계: UI 레이아웃 통합 (`tree_detail_screen.dart`)

- **섹션 1: 기본 정보**: 이름(한글/학명), 구분(침엽수/활엽수), 난이도(1-5) 편집 필드 복구.
- **섹션 2: 수목 설명**: 기존 설명 필드 유지.
- **섹션 3: 퀴즈 오답 설정**: 퀴즈 오답(Distractors) 동적 리스트 편집 기능 복구.
- **섹션 4: 부위별 힌트**: 최근 추가된 5종 힌트(대표, 수피, 잎, 꽃, 열매) 입력 필드 유지.
- **액션 바**: '저장' 버튼(전체 필드 업데이트), '보기' 버튼(미리보기 다이얼로그) 유지.

### 3단계: 로직 검증

- `_saveHints` 메서드를 `_saveFullTree`로 확장하여 전체 `CreateTreeRequest`를 전송하도록 수정.
- 이미지 리스트 유지 및 힌트 값만 정확히 매핑하여 소실 방지.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **UI 스타일**: `NeoColors.acidLime`과 `Color(0xFF1E2518)` 배경을 사용하여 일관된 다크 테마 유지.
- **접근성**: `SingleChildScrollView`를 통해 모든 입력 필드(총 12개 이상)에 원활하게 접근 가능하도록 구성.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `tree_detail_screen.dart`: `TextEditingController` 추가 (이름, 학명, 오답 리스트용).
- [ ] `initState`: 모든 기존 데이터 로드 및 컨트롤러 초기화.
- [ ] `build`: 섹션별 입력 폼 배치 (기본 정보 -> 설명 -> 오답 -> 힌트).
- [ ] `save`: `updateTree` API 호출 시 전체 필드 포함.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **데이터 유실**: 수목 수정 시 기존 이미지를 유지하며 힌트만 변경해야 하므로 `copyWith` 로직을 정밀하게 확인.
- **오답 리스트 동적 제어**: 오답 리스트가 0개 이상일 수 있으므로 동적 컨트롤러 관리 로직 점검.
- **필드 중복**: `AddTreeScreen`과 기능이 중복되므로, 추후 두 화면을 하나로 통합할지 검토 필요 (현재는 복구 우선).
