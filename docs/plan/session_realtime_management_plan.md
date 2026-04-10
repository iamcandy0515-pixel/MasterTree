# [작업계획서] 실시간 세션 관리 및 1인 1기기 정책 고도화 (V1.2)

## 1. 개요 및 목적
`DEVELOPMENT_RULES.md` 가이드라인을 준수하며, 사용자 앱(`flutter_user_app`)의 세션 안정성을 확보하고 중복 로그인을 실시간으로 차단하는 'Eviction(퇴출)' 로직을 구현합니다.

## 2. 개발 환경 및 준수 사항 (Compliance)
- **프레임워크**: Flutter `3.7.12` / Dart `2.19.6` (임의 변경 금지)
- **파일 관리**: 단일 소스 파일 **200줄 제한** 준수 (초과 시 모듈 분리)
- **웹 격리**: 웹 전용 로직(UUID 생성 등) 구현 시 `WebUtils` 추상화 레이어 활용
- **터미널**: 모든 명령어 실행 전 `chcp 65001` 설정 확인

## 3. 핵심 아키텍처: Hybrid Session Watchdog
- **진실 원천 (SoT)**: `public.users` 테이블의 `last_session_id`, `last_device_id`.
- **감지 레이어**:
    1. **Realtime Layer**: Supabase Stream을 통한 즉각적인 세션 변경 감지.
    2. **Interceptor Layer**: 모든 요청 시 DB와 세션 지문 대조.
    3. **Lifecycle Layer**: 앱 복귀(Resume) 시 세션 일치성 재확인.

## 4. 상세 작업 To-Do List

### [T1] 기기 식별 고도화 및 웹 격리 (Fingerprinting)
- [ ] `flutter_user_app/lib/core/device_info_service.dart` 수정.
- [ ] 웹 브라우저 식별을 위한 영구 UUID 생성 로직 구현.
- [ ] **[Rule 4-4]** `dart:html` 직접 참조 금지, 추상화 클래스를 통한 컴파일 에러 방지.

### [T2] 실시간 세션 구독 서비스 구현 (Realtime Monitor)
- [ ] `flutter_user_app/lib/core/supabase_service.dart` 내 `stream` 구독 로직 추가.
- [ ] **[Rule 1-1]** 기존 서비스 코드가 200줄을 초과할 경우 `lib/services/session_monitor_service.dart`로 분리.
- [ ] 타 기기 로그인 감지 시 전역 로그아웃 콜백 트리거 구현.

### [T3] API 인터셉터 보안 강화 (Interceptor)
- [ ] `lib/core/api/base_api_service.dart`의 `Dio` 인터셉터 수정.
- [ ] 요청 시 DB의 `last_session_id`와 로컬 세션 비교 로직 추가.
- [ ] 불일치 시 `SESSION_EXPIRED` 예외 처리 및 로그인 화면 리다이렉트.

### [T4] 성능 최적화 및 안정성 검증
- [ ] 중복 로그인 감지 시 안내 팝업(UI) 및 데이터 초기화 로직 보강.
- [ ] **[Rule 0-4]** 수정 전/후 `diff` 분석을 통한 소스 정합성 체크.
- [ ] **[Rule 3-2]** `flutter analyze`를 실행하여 린트 및 문법 오류 제로(0) 확인.

## 5. 예상 리스크 및 대응
- **웹 빌드 이슈**: `WebUtils` 미사용 시 모바일 빌드 실패 가능성 -> 추상화 레이어 적용 확인.
- **Realtime 연결 유실**: WebSocket 끊김 대비 API 인터셉터를 통한 2단계 방어선으로 상호 보완.
- **의존성 충돌**: 새로운 패키지(uuid 등) 추가 시 Gradle 버전 충돌 방지를 위한 `configurations.all` 설정 검토.

---
> [!IMPORTANT]
> **개발자 승인 대기**: 본 계획서 검토 후 승인이 떨어지기 전에는 실제 소스 수정을 절대 진행하지 않습니다.
