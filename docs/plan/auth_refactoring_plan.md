# 📝 인증 관련 소스 리팩토링 및 개발 규칙 준수 작업 계획서

본 계획서는 `DEVELOPMENT_RULES.md`의 규칙(200줄 제한, 웹 격리, 린트 준수 등)을 충족하기 위해 `supabase_service.dart`와 `auth_viewmodel.dart`를 리팩토링하는 과정을 담고 있습니다.

## 1. 분석 결과 및 개선 방향

- **[규칙 1-1] 200줄 제한:** `supabase_service.dart`(264줄) 및 `auth_viewmodel.dart`(207줄) 초과 확인.
- **[규칙 4-4] 웹 관련 코드 격리:** `supabase_service.dart` 내 `dart:io` 의존성 제거 필요.
- **[규칙 3-2] 린트 준수:** 13개의 정적 분석 경고 해결 필요.

## 2. 작업 To-Do List

### Phase 1: 기반 인프라 분리 (Infrastructure Splitting)
- [ ] `lib/core/device_info_service.dart` 생성
    - `SupabaseService.getDeviceInfo` 로직 이관.
    - `dart:io`와 `kIsWeb`을 활용하여 모바일/웹 환경별 안전한 기기 정보 추출 구현.
- [ ] `lib/core/config_service.dart` 생성 (선택 사항 또는 SupabaseService 내 정리)
    - 입장 코드 관련 API 호출 및 검증 로직 이관.

### Phase 2: `SupabaseService` 리팩토링
- [ ] `lib/core/supabase_service.dart` 수정
    - 불필요한 임포트(`shared_preferences`) 제거.
    - 기기 정보 로직 제거 (Phase 1 서비스 활용).
    - 문자열 보간(String interpolation) 린트 수정.
    - 최종 라인 수 200줄 미만 달성 확인.

### Phase 3: `AuthViewModel` 및 로직 핸들러 정리
- [ ] `lib/viewmodels/auth_validator.dart` (Mixin) 생성
    - `validateName`, `validatePhone` 등 검증 로직 이관.
- [ ] `lib/viewmodels/auth_viewmodel.dart` 수정
    - 검증 로직을 `AuthValidator` 믹스인으로 분리.
    - `handleLogin` 내부의 상세 처리 절차를 `AuthLogicHandler`로 추가 이관하여 슬리밍.
    - 최종 라인 수 180줄 이하 달성 확인.
- [ ] `lib/viewmodels/auth_logic_handler.dart` 수정
    - Dead null-aware expressions (??, ?) 린트 경고 수정.

### Phase 4: 최종 검증
- [ ] `flutter analyze` 재실행하여 '0 issues found' 확인.
- [ ] `DEVELOPMENT_RULES.md` 체크리스트 최종 점검.

## 3. 예상 변경 파일 경로

- `flutter_user_app/lib/core/device_info_service.dart` (New)
- `flutter_user_app/lib/viewmodels/auth_validator.dart` (New)
- `flutter_user_app/lib/core/supabase_service.dart` (Modified)
- `flutter_user_app/lib/viewmodels/auth_viewmodel.dart` (Modified)
- `flutter_user_app/lib/viewmodels/auth_logic_handler.dart` (Modified)

---
**작업 시작 전 개발자님의 승인을 요청드립니다.**
