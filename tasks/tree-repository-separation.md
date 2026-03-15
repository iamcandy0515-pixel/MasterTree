# 🧩 Task: TreeRepository Separation & Modularization

## 1. 개요
현재 712라인에 달하는 `TreeRepository`를 4개의 도메인별 리포지토리로 분리하여 코드 가독성을 높이고 유지보수성을 확보합니다. `DEVELOPMENT_RULES.md`의 200줄 제한 원칙을 준수합니다.

## 2. 전략적 결정 (Socratic Gate 반영)
- **DI 방식**: 도메인별 개별 리포지토리를 각 ViewModel에 직접 주입.
- **공통화**: `BaseRepository`를 통해 HTTP 통신 및 인증 로직 중복 제거.
- **교체 전략**: 신규 리포지토리 생성 후 ViewModel 일괄 교체 및 기존 파일 삭제.

## 3. 세부 To-Do List

### Phase 1: 기반 및 공통 모듈 구축
- [x] 0. 작업 전 상태 확인 및 `chcp 65001` 설정
- [x] 1. `BaseRepository` 클래스 생성 (`flutter_admin_app/lib/core/repositories/base_repository.dart`)
    - [x] `_baseUrl`, `_getHeaders()`, `_checkAuthError()` 이동 및 추상화

### Phase 2: 도메인별 리포지토리 분리
- [x] 2. `MasterTreeRepository` 생성 (수목 CRUD, 엑셀/CSV, 외부 API)
    - [x] 위치: `flutter_admin_app/lib/features/trees/repositories/master_tree_repository.dart`
- [x] 3. `TreeGroupRepository` 생성 (유사종 그룹 관리)
    - [x] 위치: `flutter_admin_app/lib/features/trees/repositories/tree_group_repository.dart`
- [x] 4. `SystemSettingsRepository` 생성 (설정, 서버 제어)
    - [x] 위치: `flutter_admin_app/lib/features/dashboard/repositories/system_settings_repository.dart`
- [x] 5. `StatsRepository` 생성 (대시보드/사용자 통계)
    - [x] 위치: `flutter_admin_app/lib/features/dashboard/repositories/stats_repository.dart`

### Phase 3: ViewModel 및 UI 연동 수정
- [x] 6. `TreeListViewModel` 등 수목 관련 ViewModel 리포지토리 교체
- [x] 7. `TreeGroupManagementViewModel` 등 그룹 관련 ViewModel 리포지토리 교체
- [x] 8. `SettingsViewModel`, `DashboardViewModel` 설정 관련 리포지토리 교체
- [x] 9. `StatisticsViewModel`, `UserDetailViewModel` 통계 관련 리포지토리 교체

### Phase 4: 검증 및 정리
- [x] 10. `flutter analyze` 실행 및 린트 에러 해결 (정적 분석 완료)
- [x] 11. 구형 `TreeRepository.dart` 파일 삭제
- [x] 12. 최종 Git 커밋 (리팩토링 완료)
