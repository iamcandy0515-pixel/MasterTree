# 작업 계획서 v2: 수목 상세 정보 및 부위별 힌트 매칭 보강 (admin-tree-detail-hint-v2)

## 1. 개요 (Analysis & Planning)

### 1.1. 현상 분석

- '수목도감 일람 상세' 화면에서 특정 부위(예: 꽃, 열매)에 이미지가 없는 경우, 해당 부위의 힌트가 저장되지 않거나 유실되는 현상 발생.
- 현재 시스템은 `tree_images` 테이블의 `hint` 컬럼을 사용하며, 이미지가 존재해야만 힌트가 저장되는 종속적인 구조임.

### 1.2. 핵심 전략: 힌트 매칭 로직 활용

- **DB 스키마 활용**: `tree_images` 테이블의 `image_url` 허용성(Allow NULL)을 활용하여, 이미지가 없더라도 부위별(image_type) 힌트 전용 레코드를 생성함.
- **5대 카테고리 매칭**: '대표(main)', '잎(leaf)', '수피(bark)', '꽃(flower)', '열매/겨울눈(fruit)' 5개 부위에 대해 1:1 매칭 저장 로직 구현.
- **원자적 업데이트**: 기존 이미지를 모두 삭제하고 새로 삽입하는 방식에서, 힌트 전용 레코드를 포함하여 데이터 무결성을 유지하는 방식으로 개선.

## 2. 세부 작업 내용 (Implementation Details)

### 2.1. 백엔드(Node.js API) 고도화

- `tree_images` 저장 시 `image_url`이 `null`인 경우에도 정상적으로 `hint`를 저장할 수 있도록 `TreeService.update` 로직 수정.
- `update` 메서드 내에서 이미지 데이터 삽입 시 발생하는 DB 에러를 명시적으로 체크하여 트랜잭션 실패를 방지.

### 2.2. 프론트엔드(Flutter Admin) 수정

- **TreeDetailViewModel.dart**:
    - `saveHints` 메서드 개선: 5개 표준 카테고리에 대해 루프를 돌며, 이미지가 없는 카테고리에 힌트가 입력된 경우 `imageUrl: null`인 `TreeImage` 객체를 생성하여 전송 목록에 포함.
    - 저장 후 서버로부터 반환된 최신 수목 정보(`tree_images` 포함)를 `this.tree`에 즉시 반영하여 UI 동기화.
- **TreeImage 모델**:
    - `image_url`이 `null`일 때의 직렬화/역직렬화 안정성 확보.

## 3. To-Do List

### 3.1. 백엔드 로직 강화

- [ ] `nodejs_admin_api/src/modules/trees/trees.service.ts`: `insertImages` 에러 핸들링 및 `null` URL 허용 확인.

### 3.2. 프론트엔드 매칭 로직 구현

- [ ] `flutter_admin_app/lib/features/trees/viewmodels/tree_detail_viewmodel.dart`:
    - `hintControllers` 기반의 5대 부위 힌트 수집 로직 구현.
    - 이미지가 없는 부위에 대한 가상 `TreeImage` 레코드 생성 로직 추가.
    - 서버 응답값 기반의 로컬 모델 갱신.

### 3.3. 검증 및 테스트

- [ ] 이미지가 없는 '겨울눈' 항목에 힌트만 입력 후 저장.
- [ ] DB에 `image_type='fruit'`, `image_url=null`, `hint='내용'`으로 저장되는지 확인.
- [ ] 상세 화면 재진입 시 해당 힌트가 정상적으로 불러와지는지 확인.

## 4. 리스크 관리

- **중복 레코드 방지**: 동일한 `image_type`에 대해 이미지 레코드와 힌트 전용 레코드가 중복되지 않도록 클라이언트 측에서 병합(Merge) 로직 수행.
