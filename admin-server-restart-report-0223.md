# 관리자 서버 재기동 및 불필요 프로세스 정리 보고

## 1. 목적 (Plan)

- 백그라운드에 불필요하게 떠 있는 개발 서버 세션들(`node`, `dart`, `turbo`)을 모두 강제 종료하여 메모리 및 포트 점유를 해제합니다.
- 관리자 권한 API(Node.js)와 앱(Flutter) 2개의 서버만 새롭게 터미널에 띄워서 깨끗한 환경에서 테스트 및 관리를 할 수 있도록 지원합니다.

## 2. 작업 내용 (Execute)

- PowerShell의 `Stop-Process` 명령을 사용하여 이름이 `node`, `dart`, `turbo` 인 모든 프로세스를 강제로 `Kill(-Force)` 처리했습니다. 이로 인해 메모리를 점유하던 좀비 세션들이 모두 정리되었습니다.
- 단일 모노레포 폴더 경로(`d:\MasterTreeApp\tree_app_monorepo`)에서 터보레포(Turborepo) 명령어를 사용해 두 개의 타겟 프로젝트만 동시에 병렬로 재기동시켰습니다.
    ```powershell
    npx turbo run dev --filter=nodejs_admin_api --filter=flutter_admin_app
    ```

## 3. 사후 점검 및 URL (Review)

- **Result (결과):** 불필요한 프로세스는 모두 소멸되었고, 새 터미널 창을 통해 서버가 정상적으로 부팅되었습니다.
- **Server URLs (서버 주소):**
    - 🌐 **Flutter Admin App (프론트엔드 관리자 앱):** [http://localhost:8081](http://localhost:8081)
    - ⚙️ **Node.js Admin API (백엔드 관리자 서버):** [http://localhost:3000](http://localhost:3000)
- **Risk Analysis:**
  간헐적으로 `8081` 포트 릴리스가 지연될 경우 Flutter가 `8082` 등 대체 포트를 잡을 가능성이 있습니다. 브라우저에서 8081이 응답하지 않으면 터미널 로그를 확인하여 변동된 포트가 있는지 확인하면 됩니다.
