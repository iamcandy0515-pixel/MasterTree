# 관리자 서버 재기동 (프로세스 정리 및 초기화)

## 1. 목적 및 범위 (Plan)

- 이전 백그라운드에 남아있어 포트를 점유하고 있는 `node`, `dart`, `turbo`의 고아(Zombie) 프로세스들을 전부 강제 종료.
- Flutter Admin Web App과 Node.js Admin API 서버를 초기 상태로 클린하게 재기동.

## 2. 작업 내용 (Execute)

- PowerShell 환경에서 `Get-Process node, dart, turbo -ErrorAction SilentlyContinue | Stop-Process -Force` 명령을 사용하여 기존 프로세스를 모두 죽임.
- 곧이어 `npx turbo run dev --filter=nodejs_admin_api --filter=flutter_admin_app` 명령을 통해 모노레포 관리자 관련 2가지 패키지를 동시 통합 실행.

## 3. 사후 점검 (Review)

- **Result:** 백엔드 API와 프론트엔드 Web 모두 충돌 없이 성공적으로 포트에 바인딩되었습니다. 접속 주소는 다음과 같습니다:
    - **Flutter Admin Web (프론트 관리자앱):** `http://localhost:8081`
    - **Node.js API (백엔드 서버):** `http://localhost:3000`
- **Risk Analysis:** 기존 찌꺼기 프로세스를 주기적으로 닦아내는 스크립트화가 필요할 수 있으며, flutter dev 서버의 특성상 포트 선점에 민감하므로 `8081` 번 포트에 문제가 생겼을 경우 즉각 `Stop-Process`로 정리하는 습관이 쾌적함을 유지하는 핵심입니다.
