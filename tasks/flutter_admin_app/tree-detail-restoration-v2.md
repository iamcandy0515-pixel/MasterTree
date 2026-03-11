# Task: Tree Detail Screen Full Restoration & Google Drive Image Integration (v2)

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 분석

- **현상:** 현재 '수목일람 상세화면(`TreeDetailScreen`)'은 수목 설명과 부위별 힌트 수정 기능만 노출되고 있음. 수목의 기본 필드(이름, 학명, 분류 등)의 편집 기능이 유실된 상태임.
- **요구사항:**
    1. 기존 `AddTreeScreen` 수준의 **전체 수목 정보 편집 기능을 복구**.
    2. '설정(Settings)' 메뉴에서 관리되는 **'수목 이미지 구글 드라이브 URL'**을 참조하여, 현재 수목에 맞는 이미지를 자동으로 추출/연동하는 기능을 통합.
    3. 수목의 5대 부위(대표, 수피, 잎, 꽃, 열매) 이미지와 힌트를 한 화면에서 관리 가능하게 구성.

### 1-2. 이미지 추출 로직 (Google Drive)

- **Settings 참조:** `TreeRepository.getTreeImageDriveUrl()`을 통해 설정된 드라이브 폴더의 공개 링크를 기반으로 동작.
- **매칭 규칙:** 수목 한글명(`name_kr`)을 키워드로 하여 드라이브 내 파일명(`{수목명}_대표.jpg`, `{수목명}_수피.jpg` 등)을 매칭.
- **Backend 연동:** `TreeRepository.batchSearchDriveImages(treeName)` API를 활용하여 이미지를 검색하고, 결과 URL을 `TreeImage` 객체로 변환하여 할당.

## 2. PLANNING (작업 단계별 계획)

### 1단계: 수목일람 상세화면 UI 복구 (`TreeDetailScreen`)

- **기본 정보 섹션:** 이름(한글/학명), 구분(침엽수/활엽수), 난이도(1-5) 편집 필드 다시 배치.
- **퀴즈 오답 섹션:** `List<String> quizDistractors`를 동적으로 편집(추가/삭제)할 수 있는 UI 복구.
- **설명 섹션:** 기존 설명(`description`) 입력 필드 유지.

### 2단계: 구글 드라이브 이미지 추출 연동

- **추매 기능 추가:** 상단 또는 이미지 섹션에 '구글 드라이브에서 이미지 가져오기' 버튼 추가.
- **자동 매칭:** 버튼 클릭 시 현재 `name_kr`을 기준으로 백엔드 API 호출.
- **임시 할당:** 검색된 결과가 있으면 5대 부위별로 '드라이브 이미지' 뱃지와 함께 화면에 표시 (저장 버튼 클릭 전까지는 로컬/메모리 상태 유지).

### 3단계: 부위별 힌트 및 관리 통합

- 각 부위별(대표, 수피, 잎, 꽃, 열매) 힌트 텍스트 필드와 이미지 미리보기를 결합된 위젯으로 재구성.
- `ImagePicker`를 통한 갤러리 선택 기능도 병행 지원.

### 4단계: 통합 저장 로직 구현

- `_saveFullTree` (또는 기존 `_saveHints` 확장):
    - 수정된 기본 정보 + 오답 리스트 + 설명 + 힌트 업데이트 이미지를 모두 포함한 `CreateTreeRequest` 전송.
    - `TreeRepository.updateTree(id, request)` 호출.

## 3. SOLUTIONING (디자인 및 아키텍처)

- **데이터 흐름:** `SettingsViewModel`에서 드라이브 URL을 확인하거나, 백엔드가 서버 세팅값을 사용하도록 일관성 유지.
- **UI 일관성:** `Flutter Admin App`의 전용 Neo-Dark 테마(NeoColors.acidLime)를 전면 적용하여 세련된 대시보드 느낌 강화.

## 4. IMPLEMENTATION (주요 수정 사항)

- [ ] `tree_detail_screen.dart`:
    - `TextEditingController` 배열 (오답 리스트용) 및 기본 필드용 추가.
    - `fetchFromDrive` (SourcingViewModel의 로직 이식 또는 공유) 기능 구현.
    - 구글 드라이브에서 가져온 이미지를 '임시 스테이징' 하는 상태 관리 추가.
- [ ] `tree_repository.dart`:
    - `updateTree` 메서드가 `images` 필드 내의 `hint` 속성을 정확히 백엔드에 전달하는지 재확인.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **CORS 및 프록시**: 구글 드라이브 원본 이미지는 브라우저에서 직접 표시되지 않을 수 있으므로, 기존에 구현된 `TreeRepository.getProxyUrl`을 반드시 거치도록 처리.
- **동기화 지연**: 대량의 이미지 검색 시 `isLoading` 상태를 명확히 표시하여 사용자 이탈 방지.
- **데이터 소실**: '저장' 버튼을 누르기 전까지는 원본 데이터가 변경되지 않도록 상태(State)와 원본(Prop)을 명확히 분리.
