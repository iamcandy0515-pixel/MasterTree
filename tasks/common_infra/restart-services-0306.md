# restart-services-0306.md - 프로세스 재기동 및 테스트 환경 준비

## 1. 상태 기록 (Plan)

- **목적**: 사용자 및 관리자 화면 테스트를 위해 불필요한 프로세스를 정리하고 백엔드 API와 프론트엔드 앱을 재기동함.
- **작업 범위**:
    1.  `npm run kill-all`을 통한 기존 node, dart, chrome 프로세스 완전 종료.
    2.  `flutter_admin_app`, `flutter_user_app` 의 의존성 확인 (`flutter pub get`).
    3.  `nodejs_admin_api` 백엔드 서버 기동 (Port: 4000).
    4.  `flutter_admin_app` 프론트엔드 기동 (Port: 8081).
    5.  `flutter_user_app` 프론트엔드 기동 (Port: 8082).
    6.  최종 접속 URL 보고.

---

## 2. 실행 (Execute)

- [x] 기존 프로세스 정리 (`npm run kill-all`) - 완료
- [x] Flutter 패키지 업데이트 (`flutter pub get`) - 완료
- [x] `nodejs_admin_api` 기동 (Port: 4000) - 완료
- [x] `flutter_admin_app` 기동 (Port: 8081) - 완료
- [x] `flutter_user_app` 기동 (Port: 8082) - 완료

---

## 3. 사후 점검 (Review)

- **완료된 결과(Result)**:
    - **Node JS Admin API**: [http://localhost:4000](http://localhost:4000) 에서 정상 작동 중.
    - **Flutter Admin Web**: [http://localhost:8081](http://localhost:8081) 에서 정상 작동 중.
    - **Flutter User Web**: [http://localhost:8082](http://localhost:8082) 에서 정상 작동 중.

- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - **포트 충돌**: 만약 8081, 8082, 4000 포트가 다른 서비스에 의해 이미 사용 중이라면 기동에 실패할 수 있음.
    - **브라우저 권한**: `web-server` 모드로 실행 시 자동 팝업이 되지 않을 수 있으므로 직접 URL을 입력해야 함.
    - **백엔드 연결**: 프론트엔드 `.env` 파일의 `API_URL`이 기동된 백엔드 포트(4000)와 일치하는지 재확인 필요.
