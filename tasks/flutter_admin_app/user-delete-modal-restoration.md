# [복구 작업계획서] 사용자 삭제 기능 및 확인 모달 구현 (user-delete-modal-restoration)

## 1. 개요
관리자 앱의 '사용자' 화면에서 직관적인 사용자 삭제 기능을 복구/추가합니다. 데이터의 중요성을 고려하여 삭제 시 사용자에게 명확한 경고 메시지를 보여주는 모달(AlertDialog) 시스템을 구축합니다.

## 2. 상태 분석 및 필요 기능
- **현황**: 현재 `UserCheckScreen`에는 사용자 승인/거절/활동정지 기능은 있으나, 데이터베이스에서 완전히 삭제하는 기능이 누락됨.
- **요구사항**:
    1. 사용자 리스트 각 항목에 '삭제' 아이콘 또는 버튼 추가.
    2. 클릭 시 **"삭제시 사용자의 정보가 사라집니다, 그래도 삭제하시겠습니까"** 문구가 포함된 확인창 표시. (오타 '사요자' 수정 반영)
    3. **"확인"**, **"취소"** 텍스트 버튼 배치.
    4. 실제 DB와 Auth 시스템에서 사용자 데이터 삭제 처리.

---

## 3. 상세 작업 계획 (Execute)

### Phase 1: 백엔드 API 구현 (`nodejs_admin_api`)

- [ ] **Service 확장**: `users.service.ts`에 `deleteUser(id: string)` 메서드 추가. (Supabase Auth에서도 해당 유저를 삭제하도록 `auth.admin.deleteUser` 연동)
- [ ] **Controller 연동**: `users.controller.ts`에 `deleteUser` 요청 처리 로직 추가.
- [ ] **Route 등록**: `users.routes.ts`에 `DELETE /:id` 경로 추가 (관리자 권한 검증 미들웨어 적용).

### Phase 2: 프론트엔드 통신 레이어 (`flutter_admin_app`)

- [ ] **Repository 수정**: `user_repository.dart`에 `Future<void> deleteUser(String id)` 메서드 추가 (`DELETE` 요청).
- [ ] **ViewModel 업데이트**: `user_check_viewmodel.dart`에 `deleteUser(String userId)` 기능 구현. 삭제 성공 후 목록 자동 새로고침(`loadUsers`) 로직 포함.

### Phase 3: UI 구현 및 사용자 확인창 (`UserCheckScreen`)

- [ ] **삭제 버튼 배치**: 사용자 카드 우측 상단 또는 상태 뱃지 옆에 '삭제' 텍스트 버튼 또는 아이콘 추가.
- [ ] **확인 모달 구현**:
    - `showDialog`를 사용하여 `AlertDialog` 호출.
    - **제목**: '사용자 삭제'
    - **내용**: '삭제시 사용자의 정보가 사라집니다, 그래도 삭제하시겠습니까' 
    - **버튼**: '취소' (TextButton), '확인' (TextButton, 색상: redAccent).

---

## 4. 검증 및 사후 점검 (Review)

- [ ] **기능 검증**: 삭제 클릭 시 모달이 정상적으로 뜨는지, 텍스트가 요청한 대로 표시되는지 확인.
- [ ] **데이터 검증**: '확인' 클릭 후 실제 DB와 Auth 목록에서 해당 유저가 완전히 사라지는지 확인.
- [ ] **UI 피드백**: 삭제 완료 후 SnackBar 등을 통해 '사용자가 삭제되었습니다' 메시지 출력.
