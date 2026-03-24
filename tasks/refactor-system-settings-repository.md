# 🧩 저장소 리팩토링 및 기술 명세 준수 계획서: SystemSettingsRepository

본 계획서는 `DEVELOPMENT_RULES.md` 및 `FLUTTER_3_7_12_TECH_SPEC.md`의 모든 기술 사양과 작업 규칙을 통합하여 작성되었습니다.

## 1. 개요 및 목적
- **작업 대상**: `lib/features/dashboard/repositories/system_settings_repository.dart`
- **현 상태**: 257라인 (200줄 초과), 10개 이상의 유사한 셋팅값 API 호출 로직이 중복 작성됨.
- **최종 목표**: 제네릭(Generic) 기반 HTTP 헬퍼 프라이빗 메서드 구성을 통한 100라인 이하 감축, `Flutter 3.7.12 / Dart 2.19.6` 환경에서의 완벽한 호환성 및 네트워크 처리 안정성 확보.

## 2. 기술 명세 준수 현황 (Rule & Tech Spec)
- **SDK**: Flutter `3.7.12`, Dart `2.19.6` 고정 준수.
- **Java**: `OpenJDK 17` 환경 확인 (Build Error 사전 예방).
- **Library**: `http: ^0.13.6` (명세서의 검증된 버전 활용).
- **Encoding**: `utf8.decode(response.bodyBytes)` 패턴 전면 적용하여 한글 데이터 정밀도 유지 (`Tech Spec 1.4`).
- **Encoding**: 터미널 작업 시 `chcp 65001`을 통한 UTF-8 환경 유지.

## 3. 상세 To-Do List

### 🟢 1단계: 사전 보안 및 백업 (Rule 0-1, 0-2)
- [ ] 현재 상태 로컬 Git 커밋 (`feat: pre-refactor backup for SystemSettingsRepository`)
- [ ] 터미널 인코딩 설정 확인 (`chcp 65001`)

### 🟡 2단계: 핵심 추상화 및 헬퍼 구현 (Rule 3-1)
- [ ] **_fetchSetting<T>**: 런타임 타입 세이프티를 보장하는 프라이빗 Getter 헬퍼 구현.
- [ ] **_postSetting<T>**: 에러 핸들링 및 JSON 직렬화가 내포된 프라이빗 Setter 헬퍼 구현.
- [ ] **[BaseRepository]**: `getHeaders()` 및 `checkAuthError()`의 호출 위치 최적화.

### 🟠 3단계: 개별 API 메서드 간소화 및 정합성 (Rule 1-1, 1-3)
- [ ] `getEntryCode`, `updateEntryCode` 등 각 셋팅 항목별 명시적 메서드를 헬퍼 위임 방식으로 변경 (코드 대폭 축소).
- [ ] `checkUrlStatus` 등 검증 액션 로직의 안정성 강화.
- [ ] **[Rule 1-1, 1-3] 결과**: 전체 소스 코드량을 100라인 수준으로 최적화하여 200줄 제한을 완벽하게 해결.

### 🔴 4단계: 최종 검증 (Rule 2-3, 3-2)
- [ ] **[빌드]** `flutter build web` 실행하여 컴파일 오류 및 빌드 완결성 확인.
- [ ] **[린트]** `flutter analyze` 실행하여 모든 경고 및 `prefer_final_fields` 이슈 해결.
- [ ] **[정합성]** 실제 대시보드 화면에서 시스템 설정값(입장 코드, URL 등)이 정상적으로 렌더링되고 저장되는지 기능 테스트.

---
**최종 승인 요청**: 위 중복 로직 제거 및 기술 사양 준수 계획에 대해 최종 승인을 부탁드립니다. 승인 후 작업을 시작하겠습니다.
