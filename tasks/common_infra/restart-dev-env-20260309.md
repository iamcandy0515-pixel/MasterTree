# Task: Restart Development Environment

## 1. 개요 (Overview)

개발환경 테스트를 위해 기존 프로세스를 정리하고, 클린 빌드 후 모든 서비스를 재기동합니다.

## 2. 작업 범위 (Scope)

- **대상 서비스**:
    - `nodejs_admin_api` (Port: 3000)
    - `flutter_admin_app` (Port: 8090)
    - `flutter_user_app` (Port: 8080)
- **작업 단계**:
    1. 포트 점유 프로세스 종료 (3000, 8080, 8090)
    2. Flutter 프로젝트 클린 (`flutter clean`, `flutter pub get`)
    3. API 서버 실행 (`npm run dev`)
    4. Flutter 앱 실행 (`flutter run -d chrome --web-port <PORT>`)

## 3. 상세 단계 (Plan)

### Phase 1: 프로세스 정리

- [ ] Port 3000 (API) 프로세스 확인 및 종료
- [ ] Port 8090 (Admin) 프로세스 확인 및 종료
- [ ] Port 8080 (User) 프로세스 확인 및 종료

### Phase 2: Flutter 클린 작업

- [ ] `flutter_admin_app` 디렉토리에서 `flutter clean` & `flutter pub get`
- [ ] `flutter_user_app` 디렉토리에서 `flutter clean` & `flutter pub get`

### Phase 3: 서비스 재기동

- [ ] `nodejs_admin_api`: `npm run dev` (Port 3000)
- [ ] `flutter_admin_app`: `flutter run -d chrome --web-port 8090`
- [ ] `flutter_user_app`: `flutter run -d chrome --web-port 8080`

## 4. 검증 항목 (Verification)

- 모든 서비스의 터미널 출력 확인 (정상 실행 여부)
- 접속 URL 안내
    - API: http://localhost:3000
    - Admin: http://localhost:8090
    - User: http://localhost:8080

---

## 사후 점검 (Review)

_(작업 완료 후 작성 예정)_
