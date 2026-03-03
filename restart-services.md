# 서비스 재기동 및 불필요 프로세스 정리

## 1. 상태 기록 (Plan)

- **목적**: 불필요한 프로세스(node, dart, chrome)를 강제 종료하여 메모리를 확보하고, `flutter_user_app` 및 `nodejs_admin_api`를 깨끗한 상태로 재기동함.
- **작업 범위**:
    1.  `npm run kill-all` 명령어를 통해 기존에 실행 중인 node, dart, chrome 프로세스를 모두 종료.
    2.  `nodejs_admin_api` 백엔드 서버 기동 (포트 3000).
    3.  `flutter_user_app` 사용자용 앱 기동 (포트 8080).
    4.  정상 기동 여부 확인 및 최종 URL 안내.

---

## 2. 실행 (Execute)

- [x] 불필요 프로세스 종료 (`npm run kill-all` 및 수동 종료) - 완료
- [x] 백엔드 서버 기동 (`npm run api:dev`) - 완료 (Port: 3000)
- [x] 사용자 앱 기동 (`flutter run -d chrome --web-port 8081`) - 완료 (Port: 8081)
- [x] 기동 상태 및 URL 확인 - 완료

---

## 3. 사후 점검 (Review)

- **완료된 결과 (Result)**:
    - **Node.js Admin API**: [http://localhost:3000](http://localhost:3000) 에서 정상 작동 중.
    - **Flutter User App**: [http://localhost:8081](http://localhost:8081) 에서 정상 작동 중.
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - **포트 선점 이슈**: `8080` 포트가 `AgentService`에 의해 점유되어 있어 부득이하게 사용자 앱을 `8081` 포트로 기동하였습니다.
    - **브라우저 캐시**: `Ctrl + F5`를 통해 최신 상태를 반영해 주세요.
