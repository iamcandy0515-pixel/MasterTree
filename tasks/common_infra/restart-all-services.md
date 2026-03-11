# Task: Restart All Services

## 목적 (Purpose)

불필요한 프로세스를 정리하고, 시스템의 주요 3개 서비스를 재기동하여 안정적인 개발 환경을 확보합니다.

## 범위 (Scope)

- **대상 서비스**:
    - `nodejs_admin_api` (Node.js backend)
    - `flutter_admin_app` (Flutter Web admin)
    - `flutter_user_app` (Flutter Web user)
- **작업 내용**:
    - 기존 관련 포트(3000, 8080, 8090) 프로세스 종료
    - 각 서비스 재기동
    - 접속 URL 확인 및 보고

## 실행 계획 (Execution Plan)

### Phase 1: 프로세스 정리

- [x] 포트 4000, 8081, 8090 점유 확인 및 정리
- [x] `AgentService.exe`가 8080을 점유 중임을 확인하여 사용자 앱 포트를 8081로 변경

### Phase 2: 서비스 재기동

- [x] **nodejs_admin_api**: `npm run dev` 실행 완료 (포트 4000)
- [ ] **flutter_user_app**: `flutter run -d chrome --web-port 8081` 실행 중
- [ ] **flutter_admin_app**: `flutter run -d chrome --web-port 8090` 실행 중

### Phase 3: 최종 확인

- [ ] 각 서비스의 정상 구동 여부 확인
- [ ] 최종 접속 URL 정리 및 개발자님께 보고

## 위험 분석 및 리스크 (Risk Analysis)

- **포트 충돌**: 다른 프로세스가 해당 포트를 강하게 점유하고 있을 경우 기동이 실패할 수 있음.
- **빌드 오류**: Flutter 앱 기동 시 종속성 문제로 에러가 발생할 수 있으며, 이 경우 `flutter clean` 및 `pub get`이 필요할 수 있음.
- **리소스 부족**: 3개 서비스를 동시에 띄울 때 메모리 점유율이 높아져 반응이 느려질 수 있음.
