# Task: Restart Apps for Testing

## Status 기록 (Plan)

- **목적**: 사용자 및 관리자 화면 테스트를 위해 기존 프로세스를 정리하고 최신 상태로 재빌드 및 재기동
- **범위**:
    - `flutter_admin_app`
    - `flutter_user_app`
    - `nodejs_admin_api`
- **사용 포트 예상**:
    - Admin App: 8090
    - User App: 8080
    - Node.js API: 3000

## 실행 (Execute)

1. [x] 불필요한 프로세스 종료 (Port 8080, 8090, 3000)
2. [x] `flutter_admin_app`: `flutter clean` & `flutter pub get`
3. [x] `flutter_user_app`: `flutter clean` & `flutter pub get`
4. [x] `nodejs_admin_api`: 서버 시작 (`npm run dev`)
5. [x] `flutter_admin_app`: Chrome 실행 (Port 8090)
6. [x] `flutter_user_app`: Chrome 실행 (Port 8081) - _8080 충돌로 변경_

## 사후 점검 (Review)

- **완료된 결과 (Result)**: API 및 앱 2종 정상 기동 완료. 사용자 앱은 포트 8080 점유 이슈로 8081로 실행됨.
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - 8080 포트가 시스템 권한에 의해 차단됨(errno 10013). 추후 포트 점유 원인 파악 필요.
    - 포트 번호가 8081로 변경됨에 따라 관련 설정 확인 요망.
