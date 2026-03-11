# Task: 프로젝트 전반 5대 카테고리 변수명 표준화 (main 통합)

## 상태 기록 (Plan)

### 1. 작업 목적

- DB 표준인 `main`을 기준으로 프로젝트 전 계층(API, Flutter Admin/User, 스크립트)의 변수명을 일원화하여 데이터 가독성과 매칭 정확도를 높임.

### 2. 표준 정의

| 카테고리 (한글) | 표준 변수명 (영문) |
| :-------------- | :----------------- |
| **대표**        | **`main`**         |
| **수피**        | **`bark`**         |
| **잎**          | **`leaf`**         |
| **꽃**          | **`flower`**       |
| **열매**        | **`fruit`**        |

### 3. 작업 범위

- **백엔드 (Node.js)**
    - `google_drive.service.ts`: Google Drive 추출 시 `대표` -> `main` 매핑.
- **프론트엔드 (Flutter Admin)**
    - `tree_sourcing_viewmodel.dart`: ViewModel 내 `representative`를 `main`으로 변경 및 임시 변환 로직 제거.
    - `tree_sourcing_detail_screen.dart`: UI 호출 인자 `representative` -> `main` 변경.
    - `tree_detail_screen.dart`: 초기화 로직의 `main` -> `representative` 변환 코드 제거.
    - `image_processing_util.dart`: 카테고리 표시 함수 내 `representative` 케이스 정리.

## 실행 (Execute)

### 단계 1: 백엔드 매핑 수정

- `google_drive.service.ts`의 `typeMap` 수정.

### 단계 2: 프론트엔드 ViewModel 수정

- `tree_sourcing_viewmodel.dart` 수정.

### 단계 3: 프론트엔드 Screen 및 Util 수정

- `tree_sourcing_detail_screen.dart`, `tree_detail_screen.dart`, `image_processing_util.dart` 수정.

## 사후 점검 (Review)

- **완료된 결과 (Result)**:
    - **백엔드**: `google_drive.service.ts`에서 `대표` 매핑을 `main`으로 수정 완료.
    - **Admin 앱 (ViewModel)**: `TreeSourcingViewModel`에서 `representative`를 `main`으로 변경하고 타입 변환 로직 제거 완료.
    - **Admin 앱 (UI)**: `TreeSourcingDetailScreen`, `TreeDetailScreen`, `SpeciesSelectionSection`에서 모든 `representative` 호출 및 상태 변수를 `main`으로 교체 완료.
    - **User 앱**: `TreeComparisonProcessor`, `TreeListController`에서 매핑 규칙을 `main`으로 단일화 완료.
    - **공통 유틸**: `ImageProcessingUtil`에서 `main`을 표준으로 확정.
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - 모든 계층이 `main`으로 통일되어 데이터 매칭 오류가 해결되었습니다.
    - 향후 데이터 추가 시 '대표' 카테고리는 반드시 `main` 키를 사용해야 하며, 구글 드라이브 파일명 역시 `_대표` 패턴을 유지해야 합니다.
