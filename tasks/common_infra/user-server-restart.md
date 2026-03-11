# Task: User Server Restart & Cleanup

## 1. 상태 기록 (Plan)

- **목적**: 불필요한 프로세스(node, dart, chrome)를 강제 종료하고, 사용자 서버 2개(`flutter_user_app`, `nodejs_admin_api`)를 재기동함.
- **작업 범위**:
    1.  `taskkill`을 이용한 기존 관련 프로세스 전체 종료.
    2.  `nodejs_admin_api` 백엔드 서버 기동 (포트 3000).
    3.  `flutter_user_app` 프론트엔드 서버 기동 (Chrome 브라우저 대상).
    4.  최종 접속 URL 확인 및 보고.

---

## 2. 실행 (Execute)

- [x] 불필요 프로세스 종료 (`npm run kill-all`) - 완료
- [x] 백엔드 서버 기동 (`npm run api:dev`) - 완료 (Port: 3000)
- [x] 사용자 앱 기동 (`flutter run -d chrome`) - 완료 (Port: 8080)
- [x] 기동 상태 확인 및 URL 추출 - 완료

---

## 3. 사후 점검 (Review)

- **완료된 결과(Result)**:
    - `nodejs_admin_api`: [http://localhost:3000](http://localhost:3000) 에서 정상 작동 중.
    - `flutter_user_app`: [http://localhost:8080](http://localhost:8080) (Chrome) 에서 정상 작동 중.
    - 기존 모든 node, dart, chrome 프로세스를 정리하여 메모리 최적화 완료.
- **향후 문제점 및 리스크 분석(Risk Analysis)**:
    - **포트 고정**: 사용자용 플러터 앱이 포트 8080을 점유하므로, 다른 앱 기동 시 충돌 주의가 필요합니다.
    - **API 연결**: 프론트엔드에서 백엔드로의 연결이 `localhost:3000`으로 정상 설정되어 있는지 확인되었습니다.
- **인증 오류**: `Anonymous sign-ins are disabled` 에러가 발생할 경우, Supabase 대시보드에서 해당 기능을 활성화해야 합니다. 코드상에서는 크래시 방지 처리가 완료되었습니다.
