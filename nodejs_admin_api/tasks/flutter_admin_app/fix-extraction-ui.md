# Task: 이미지 추출 상세 화면 UI 수정 및 데이터 로딩 이슈 해결

## 상태 기록 (Plan)

### 1. 작업 목적

- 관리자 앱의 '이미지 추출 상세' 화면 UI 개선 및 데이터 표시 오류 해결.
- '대표 이미지'가 화면 진입 시 표시되지 않는 문제(DB 필드명 mismatch) 해결.

### 2. 작업 범위

- **제목 변경**: `${tree.nameKr} 이미지 & 썸네일 관리` -> `이미지 추출 상세`.
- **수목명 표시**: '대표 이미지' 섹션 위에 수목명(`${tree.nameKr}`) 추가 표시.
- **데이터 로딩 이슈 해결**: DB의 `main` 타입을 UI의 `representative` 타입으로 매핑하여 기존 이미지가 정상적으로 출력되도록 수정.

### 3. 기술적 분석

- **필드명 불일치**:
    - DB/Service: `main`
    - Google Drive Extraction API: `representative`
    - Flutter UI: `representative`
- **해결책**: `TreeSourcingViewModel.getImageByType`에서 `main`을 `representative`로 정규화하여 반환.

## 실행 (Execute)

### 단계 1: UI 수정 (`tree_sourcing_detail_screen.dart`)

- AppBar 타이틀 수정.
- ListView 최상단에 수목명 텍스트 위젯 추가.

### 단계 2: 데이터 매핑 수정 (`tree_sourcing_viewmodel.dart`)

- `getImageByType` 메서드에서 `main` -> `representative` 변환 로직 추가.

## 사후 점검 (Review)

- **완료된 결과 (Result)**:
    - `TreeSourcingDetailScreen`의 타이틀을 '이미지 추출 상세'로 변경하였습니다.
    - 섹션 상단에 수목명(`${tree.nameKr}`)을 크게 표시하였습니다.
    - `TreeSourcingViewModel.getImageByType`에서 `main` 타입을 `representative`로 자동 매핑하도록 수정하여 화면 진입 시 기존 이미지가 보이지 않던 문제를 해결하였습니다.
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - 현재 DB와 Extraction API 간의 필드명 불일치(`main` vs `representative`)가 근본적인 원인입니다.
    - 임의의 ViewModel에서 매핑 처리를 했으나, 향후 데이터 일관성을 위해 DB 필드명을 한 가지로 통일하는 마이그레이션을 권장합니다.
