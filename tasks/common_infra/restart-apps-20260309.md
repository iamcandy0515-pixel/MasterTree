# 서비스 재기동 및 클린 빌드 테스트 환경 구축

## 1. 상태 기록 (Plan)

- **목적**: 불필요한 프로세스를 정리하고, 두 Flutter 앱(`admin`, `user`)의 클린 빌드를 수행한 뒤, 백엔드 API와 함께 Chrome에서 재기동하여 통합 테스트 환경을 구축함.
- **작업 범위**:
    1.  **프로세스 정리**: `node`, `dart`, `chrome` 관련 프로세스를 강제 종료.
    2.  **클린업**: `flutter_admin_app`, `flutter_user_app` 디렉토리에서 `flutter clean` 및 `flutter pub get` 수행.
    3.  **서비스 기동**:
        - `nodejs_admin_api`: [http://localhost:3000](http://localhost:3000) (npm run dev)
        - `flutter_admin_app`: [http://localhost:8090](http://localhost:8090) (flutter run -d chrome --web-port 8090)
        - `flutter_user_app`: [http://localhost:8081](http://localhost:8081) (flutter run -d chrome --web-port 8081)
    4.  **결과 보고**: 각 서비스의 URL 및 기동 상태 확인.

---

## 2. 실행 (Execute)

- [x] 불필요 프로세스 종료 (`npm run kill-all`) - 완료
- [x] `flutter_admin_app` Clean & Pub get - 완료
- [x] `flutter_admin_app` Build Web (CanvasKit) - 진행 중
- [ ] `flutter_user_app` Clean & Pub get - 대기 중
- [ ] `flutter_user_app` Build Web (CanvasKit) - 대기 중
- [x] `nodejs_admin_api` 기동 (`npm run dev`) - 완료 (Port: 4000)
- [ ] `flutter_admin_app` Chrome 기동 (Port: 8090)
- [ ] `flutter_user_app` Chrome 기동 (Port: 8081)

---

## 3. 사후 점검 (Review)

- **Risk Analysis**:
    - **빌드 시간**: `flutter clean` 이후 첫 실행은 빌드 시간이 평소보다 오래 걸릴 수 있습니다.
    - **포트 충돌**: `8080` 포트가 Agent에 의해 선점되어 있을 경우 `8081`로 우회 기동합니다.
    - **백엔드 연결**: API 서버가 정상적으로 응답하는지 확인이 필요합니다.
