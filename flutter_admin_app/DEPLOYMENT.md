# Flutter Admin App Deployment Guide (2-Server System)

이 문서는 MasterTreeApp 관리자 시스템의 배포 원칙과 절차를 설명합니다.

## 🚨 [필독] 핵심 배포 원칙 (Dual Server Requirement)

관리자 시스템은 **프론트엔드(Flutter Web)**와 **백엔드(Node.js API)**가 물리적으로 분리된 **2-Server 시스템**입니다.

> **CRITICAL**: 배포 환경에서도 반드시 **두 개의 서버가 독립적으로 실행**되어야 하며, 서로 통신이 가능해야 합니다. 하나라도 중단되면 서비스는 작동하지 않습니다.

---

## 1. 시스템 아키텍처 및 통신 구조

```mermaid
graph LR
    User[관리자 사용자] -->|접속 (HTTPS)| Web[Flutter Admin Web]
    Web -->|API 요청 (JSON)| API[Node.js Admin API]
    API -->|쿼리 (SQL)| DB[(Supabase DB)]
```

- **Frontend (Web)**: 사용자에게 보여지는 화면 (정적 호스팅 가능)
- **Backend (API)**: 데이터 로직 처리 및 DB 접근 (동적 서버 필요)

---

## 2. 배포 순서 (Deployment Order)

API 서버가 먼저 준비되어야 웹 프론트엔드가 데이터를 요청할 곳을 알 수 있습니다.

### Step 1: Backend 배포 (Node.js API)

1. **대상**: `tree_app_monorepo/nodejs_admin_api`
2. **배포 환경**: Node.js 18+ 지원 서버 (예: Railway, Heroku, AWS EC2, GCP Cloud Run)
3. **환경 변수 (.env)**:
    - `SUPABASE_URL`: Supabase 프로젝트 URL
    - `SUPABASE_KEY`: Supabase Service Role Key (관리자 권한)
4. **확인**: 배포 후 API URL 확보 (예: `https://api.mastertreeErrors.com`)

### Step 2: Frontend 배포 (Flutter Admin App)

1. **대상**: `tree_app_monorepo/flutter_admin_app`
2. **빌드 명령어**: `flutter build web --release`
3. **환경 변수 (.env)**:
    - `API_BASE_URL`: **Step 1에서 배포한 API 서버의 주소** (예: `https://api.mastertreeErrors.com`)
4. **배포**: `build/web` 폴더의 내용을 정적 웹 호스팅 서비스에 업로드 (예: Vercel, Netlify, Firebase Hosting, AWS S3)

---

## 3. 운영 및 유지보수 규칙

1. **상시 가동 (Always On)**
    - API 서버는 24시간 실행 상태여야 합니다. (Cold Start가 있는 경우 첫 로딩이 느릴 수 있음)
    - 웹 서버는 정적 파일이므로 별도 실행이 필요 없지만, 호스팅 상태여야 합니다.

2. **CORS 설정 (Cross-Origin Resource Sharing)**
    - **문제**: 브라우저 보안 정책으로 인해 웹(Domain A)에서 API(Domain B) 호출 시 차단될 수 있음.
    - **해결**: Backend(Node.js)의 CORS 설정에 **Frontend(Web)의 도메인**을 반드시 허용해야 함.

    ```javascript
    // nodejs_admin_api/src/server.ts 예시
    app.use(
        cors({
            origin: [
                "https://admin.mastertreeErrors.com",
                "http://localhost:8081",
            ],
            credentials: true,
        }),
    );
    ```

3. **테스트 규칙**
    - 로컬 테스트 시에도 반드시 두 서버를 모두 실행해야 합니다.
        - Backend: `npm run dev` (Port 3000)
        - Frontend: `flutter run -d chrome` (Port 8081)
