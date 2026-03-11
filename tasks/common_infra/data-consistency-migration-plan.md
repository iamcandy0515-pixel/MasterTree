# Task: 데이터 일관성 확보를 위한 필드명 통합 및 매핑 규칙 관리 계획

## 상태 기록 (Plan)

### 1. 작업 목적

- 데이터베이스의 `main` 타입을 `representative`로 통합하여 데이터 일관성을 확보.
- 한글 카테고리(대표, 수피, 잎, 꽃, 열매와 겨울눈)와 시스템 변수명 간의 매핑 규칙을 명확히 정의하고 중앙 관리함.
- 수목의 이미지와 힌트 데이터가 동일한 규칙에 따라 매칭되도록 보장함.

### 2. 매핑 규칙 정의 (Mapping Rules)

시스템 전반에서 사용할 중앙 매핑 규칙을 다음과 같이 확정함:

| 한글 카테고리     | 영문 변수명 (image_type) | 설명                                                           |
| :---------------- | :----------------------- | :------------------------------------------------------------- |
| **대표**          | `representative`         | 수목의 전체적인 모습을 나타내는 메인 이미지 (기존 `main` 대체) |
| **수피**          | `bark`                   | 나무껍질 이미지 및 힌트                                        |
| **잎**            | `leaf`                   | 나뭇잎 이미지 및 힌트                                          |
| **꽃**            | `flower`                 | 꽃 이미지 및 힌트                                              |
| **열매와 겨울눈** | `fruit`                  | 열매 또는 겨울눈 이미지 및 힌트                                |

### 3. 작업 범위 및 단계

#### [Phase 1] DB 마이그레이션 (DB Migration)

- `tree_images` 테이블의 `image_type` 값 변경: `main` -> `representative`.
- 관련 제약 조건이나 인덱스가 있다면 확인 후 조정.

#### [Phase 2] 백엔드 리팩토링 (Node.js API)

- `trees.dto.ts`: `TreeImageDto`의 `image_type` 유니온 타입 수정.
- `google_drive.service.ts`: `typeMap` 상수 및 파일 파싱 로직 업데이트.
- `TreeService`: `main`을 참조하는 모든 비즈니스 로직을 `representative`로 변경.
- `manual_fix_pine.ts` 등 주요 스크립트 수정.

#### [Phase 3] 프론트엔드 리팩토링 (Flutter Admin/User App)

- `tree.dart`: 모델 클래스의 타입 체크 로직 수정.
- `image_processing_util.dart`: `getCategoryDisplayName` 및 파일명 생성 규칙 업데이트.
- `tree_sourcing_viewmodel.dart`: ViewModel 내 정규화 로직 제거 (DB 데이터가 이미 정규화되어 있으므로).
- `tree_detail_screen.dart`: UI 매핑 로직(`_initializeData` 등) 수정.

#### [Phase 4] 검증 및 동기화 (Verification)

- 전체 수목 데이터에 대해 이미지와 힌트가 올바른 카테고리에 매칭되어 있는지 전수 조사 스크립트 실행.
- 구글 드라이브 파일명 패턴과 DB 데이터 간의 일치 여부 확인.

## 실행 (Execute) - 예정

### 단계 1: DB 마이그레이션 실행

```sql
UPDATE tree_images SET image_type = 'representative' WHERE image_type = 'main';
```

### 단계 2: 공통 매핑 상수 정의

- 백엔드: `src/constants/image_types.ts` 생성 권장.
- 프론트엔드: `lib/core/constants/category_constants.dart` 생성 권장.

## 사후 점검 (Review)

- **완료된 결과 (Result)**: (작업 실무 진행 후 기록 예정)
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - API 하위 호환성: 작업 중 API가 중단되면 사용자 앱에서 메인 이미지가 안 보일 수 있으므로 배포 순서 주의 필요.
    - 배포 순서: DB 마이그레이션 -> 백엔드 배포 -> 프론트엔드 배포 순으로 진행 권장.
