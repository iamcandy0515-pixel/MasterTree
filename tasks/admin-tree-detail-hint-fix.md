# 작업 계획서: 수목 상세 정보 및 부위별 힌트 저장 기능 정상화 (admin-tree-detail-hint-fix)

## 1. 개요 (Analysis & Planning)

### 1.1. 현상 분석
- '수목도감 일람 상세' 화면에서 '저장' 클릭 시 부위별 힌트가 DB에 반영되지 않는 현상이 보고됨.
- 분석 결과, 백엔드(`TreeService.update`)에서 이미지 데이터를 저장하는 과정 중 발생하는 에러를 무시하고 성공 응답을 보내는 구조적 결함이 발견됨.
- 또한, 프론트엔드(`TreeDetailViewModel`)에서 저장 후 서버로부터 받은 최신 데이터를 로컬 상태에 동기화하지 않아 연쇄적인 데이터 유실 가능성이 있음.

### 1.2. 원인 진단 (Root Causes)
1. **백엔드 예외 처리 누락**: `supabase.from("tree_images").insert()`의 결과를 체크하지 않아 실제 DB 저장에 실패해도 클라이언트는 성공으로 오인함.
2. **프론트엔드 상태 동기화 누락**: `updateTree` 호출 후 반환된 `Tree` 객체를 ViewModel의 `tree` 필드에 덮어쓰지 않음.
3. **이미지-힌트 매핑 한계**: 현재 로직은 기존 이미지가 있는 경우에만 힌트를 업데이트함. 새로운 부위에 힌트만 입력할 경우 저장 대상에서 제외될 수 있음.

## 2. 세부 작업 내용 (Implementation Details)

### 2.1. 백엔드(Node.js API) 고도화
- `trees.service.ts`:
    - `insertImages` 호출 시 `{ error }`를 구조 분해 할당으로 받아 에러 존재 시 `throw error` 처리.
    - 트랜잭션과 유사한 원자성을 보장하기 위해 이미지 저장 실패 시 전체 프로세스가 중단되도록 수정.

### 2.2. 프론트엔드(Flutter Admin) 수정
- `TreeDetailViewModel.dart`:
    - `saveHints` 메서드에서 `_repository.updateTree`의 반환값을 받아 `this.tree`를 업데이트.
    - 저장 성공 후 `tree` 상태가 갱신되어 새로 입력된 힌트가 UI와 모델에 영구 반영되도록 보정.
- `Tree.dart` (모델):
    - `TreeImage.toJson()`이 모든 부위(`image_type`)와 `hint`를 정확히 포함하고 있는지 재검증 (이미 완료되었으나 체크리스트 포함).

## 3. To-Do List

### 3.1. 백엔드 수정
- [ ] `nodejs_admin_api/src/modules/trees/trees.service.ts` 내 `update` 메서드 에러 처리 로직 추가.

### 3.2. 프론트엔드 수정
- [ ] `flutter_admin_app/lib/features/trees/viewmodels/tree_detail_viewmodel.dart` 상태 동기화 로직 추가.
- [ ] `flutter_admin_app/lib/features/trees/screens/widgets/detail_parts/tree_hint_section.dart` 저장 버튼 비활성화 상태 전이 확인.

### 3.3. 검증
- [ ] '가문비나무' 상세 화면에서 수피, 잎 힌트 입력 후 저장 테스트.
- [ ] 화면 새로고침 후 데이터 유지 여부 확인.

## 4. 리스크 관리
- **이미지 유실 위험**: `deleteImagesByTreeId` 후 `insertImages` 실패 시 이미지가 모두 삭제될 수 있음. 백엔드 에러 처리를 통해 이를 방지함.
