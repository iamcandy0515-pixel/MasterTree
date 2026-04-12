# [계획서] 입장코드 일원화 및 기존 사용자 코드 초기화 구현

본 계획서는 사용자 앱의 입장코드 보안 및 일관성을 강화하기 위해 기존 사용자의 고유 코드를 폐지하고 전역 설정값으로 전환하는 작업 과정을 정의합니다.

## 1. 개요
*   **목적:** 기존 가입 시점의 입장코드를 무시하고 관리자가 설정한 최신 입장코드만 사용하도록 강제함.
*   **주요 변경 사항:**
    1.  사용자 앱: 입장코드 불일치 시 서버 설정값 안내 메시지 출력.
    2.  관리자 앱: 모든 사용자의 코드를 현재 설정값으로 일괄 업데이트하는 버튼 추가.
    3.  관리자 API: 일괄 초기화용 백엔드 엔드포인트 구현.

---

## 2. 세부 작업 단계

### 하위 단계 1: 관리자 API (Back-end)
*   **경로:** `nodejs_admin_api/src/modules/settings/`
*   **작업 내용:**
    *   `settings.service.ts`: `resetAllUserEntryCodes()` 함수 구현.
        *   SQL: `UPDATE users SET entry_code = (SELECT value FROM app_settings WHERE key = 'entry_code')`
    *   `settings.controller.ts`: `resetUserEntryCodes` 핸들러 추가.
    *   `settings.routes.ts`: `POST /api/settings/reset-user-codes` 라우트 등록.

### 하위 단계 2: 관리자 앱 (Front-end)
*   **경로:** `flutter_admin_app/lib/screens/settings/`
*   **UI 변경:**
    *   '입장코드' 설정 항목 바로 아래에 '기존 사용자 입장코드 초기화' 섹션 추가.
    *   '초기화' TextButton 배치 및 확인 다이얼로그(Alert) 연결.
*   **기능 로직:**
    *   `SettingsService`에 API 호출 함수 추가.

### 하위 단계 3: 사용자 앱 (Mobile)
*   **경로:** `flutter_user_app/lib/`
*   **핵심 로직 수정 (`ConfigService`):**
    *   `isValidEntryCode`가 단순 `bool`이 아닌 상세 결과를 반환하거나, 전역 설정값과 대조 실패 시 즉시 예외 발생.
*   **메시지 처리 (`AuthViewModel`):**
    *   로그인 시도 중 입력을 받은 코드가 서버 코드와 다를 경우:
        "입장코드가 'XXXX'로 변경되었습니다. 코드를 수정해 주세요." 메시지 출력.

---

## 3. 예상 위험 요인 및 예외 처리
*   **네트워크 오류:** 서버 코드를 가져오지 못할 경우 기본 fallback('1133') 사용.
*   **사용자 혼란:** 기존 저장된 코드가 '1122'인데 자동으로 채워진 상태에서 오류가 발생하므로, 에러 메시지를 명확히 표시하여 유도.

---

## 4. 최종 점검 항목 (Linter)
*   [ ] `dart analyze` (사용자/관리자 앱)
*   [ ] `npm run lint` (관리자 API)
*   [ ] 실제 기기 로그인 테스트 (아이폰/갤럭시)
