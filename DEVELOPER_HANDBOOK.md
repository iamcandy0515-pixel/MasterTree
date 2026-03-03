# 📘 MasterTreeApp Project: Developer Handbook & Maintenance Guide

> **Purpose**: This document contains everything needed to clone, set up, and maintain the MasterTreeApp project on a new machine.
> **Target Audience**: Developers, Future Maintainers.

---

## 🛠️ 1. Environment Setup (New Machine Installation)

Follow these steps to set up the project on a fresh PC.

### 1-1. Prerequisites

Ensure the following are installed:

1.  **Node.js**: v18 or higher (LTS recommended).
    - Verify: `node -v`
2.  **Git**: Latest version.
    - Verify: `git --version`
3.  **Code Editor**: VS Code (or Cursor) recommended.

### 1-2. Cloning the Repository

```bash
git clone https://github.com/iamcandy0515-pixel/master-tree-app.git
cd MasterTreeApp
```

### 1-3. Dependency Installation

Navigate to the web directory (where Next.js lives) and install dependencies.

```bash
cd web
npm install
```

### 1-4. Environment Variables Configuration (**CRITICAL**)

Create a file named `.env.local` in the `web/` directory.
You must obtain the actual values from the Vercel Dashboard or the original PC.

**File Path**: `c:\Booking\web\.env.local`

```ini
# .env.local Template
# Retrieve these values from Supabase Dashboard > Project Settings > API

NEXT_PUBLIC_SUPABASE_URL=https://your-project-url.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-secret-anon-key...
```

### 1-5. Run Development Server

```bash
npm run dev
```

Access the app at `http://localhost:3000`.

---

## ☁️ 2. Supabase (Database) Setup

If you need to recreate the database or understand the schema.

### 2-1. Table Schema

The official SQL schema is located at:
open file: `supabase/schema.sql`

**Key Tables**:

- `trees`: Core tree identity and information.
- `tree_sections`: Part-by-part details (Leaf, Bark, etc.) for quizzes.
- `confusion_groups`: Comparison groups for similar species.

### 2-2. Row Level Security (RLS)

Refer to `SUPABASE_GUIDE.md` in the project root.
**Summary**: You MUST add "Public Read" and "Public Insert" policies, or the app will fail silently.

---

## 🚀 3. Deployment & Vercel Configuration

### 3-1. Deployment Command

The project is connected to Vercel via GitHub. Pushing to `main` branch usually triggers a deployment.

```bash
# Standard Deployment Flow
git add .
git commit -m "feat: description of changes"
git push origin main
```

### 3-2. Manual Redeploy (If Env Vars Changed)

If you updated environment variables in Vercel, you must redeploy.
**Option A (UI)**: Vercel Dashboard > Deployments > Redeploy.
**Option B (CLI Override)**:

```bash
git commit --allow-empty -m "trigger: redeploy"
git push
```

---

## 🤖 4. AI Agent & Antigravity Setup (Optional)

If you wish to use the AI Agent (Antigravity/Cursor) on the new machine:

1.  **Install Python**: v3.11+ required.
2.  **Configuration**:
    - Ensure `.agent/` folder is present in the root.
    - Ensure `mcp_config.json` is correctly set up in your user directory (machine specific).
    - Config Path: `~/.gemini/antigravity/mcp_config.json`

---

## 🔧 5. Troubleshooting & Maintenance

### 5-1. Common Issues

- **App Crash on Start**: Check `.env.local`. Missing Supabase keys will cause errors (though we added safety checks).
- **Data Not Loading**: Check Supabase RLS Policies. (See `SUPABASE_GUIDE.md`).
- **Timezone Issues**: We store dates as `YYYY-MM-DD` strings to avoid timezone shifts. Do not change this to `Date` object storage without careful testing.

### 5-2. Useful Scripts

Located in `web/` directory:

- `npm run dev`: Start local server.
- `npm run build`: Test production build (run this before pushing!).
- `npm run lint`: Check code quality.

---

# 📘 MasterTreeApp 개발자 핸드북 및 유지보수 가이드 (상세판)

> **목적**: 이 문서는 새로운 PC에서 MasterTreeApp 프로젝트를 설치, 설정, 배포 및 유지보수하는 데 필요한 모든 내용을 담고 있습니다.

## 🛠️ 1. 환경 설정 (새 PC 설치 시)

### 1-1. 필수 프로그램 설치

1.  **Node.js**: v18 이상 (LTS 버전 권장).
2.  **Git**: 최신 버전 설치.
3.  **코드 에디터**: VS Code (또는 Cursor) 설치.

### 1-2. 프로젝트 불러오기 및 실행

새 컴퓨터의 터미널(PowerShell 또는 CMD)에서 아래 순서대로 정확히 입력하세요.

```bash
# 1. GitHub에서 코드 복제
git clone https://github.com/iamcandy0515-pixel/master-tree-app.git

# 2. 프로젝트 폴더로 이동 (가장 중요)
cd MasterTreeApp/web

# 3. 필수 라이브러리 설치
npm install

# 4. 환경 변수 파일 생성 (.env.local)
# --> 아래 1-3. 환경 변수 섹션을 보고 파일을 직접 만들어야 합니다.

# 5. 개발 서버 실행
npm run dev
# 이제 인터넷 브라우저 주소창에 http://localhost:3000 입력하면 접속됩니다.
```

### 1-3. 환경 변수 (.env.local) - **가장 중요**

보안상의 이유로 GitHub에는 비밀번호가 올라가지 않습니다. 따라서 **반드시 수동으로 만들어야 합니다.**
`web` 폴더 안에 `.env.local`이라는 이름의 파일을 만들고, 아래 내용을 채워 넣으세요.

```ini
# Supabase 대시보드 -> Project Settings -> API 메뉴에서 확인 가능
NEXT_PUBLIC_SUPABASE_URL=https://본인앱주소.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=ey_매우_긴_비밀_키...
```

---

## 🚀 2. 배포 시 주의사항 (배포 전 체크리스트)

배포 또는 코드 수정 후 에러가 발생한다면 다음 내용을 **반드시 먼저 확인**하세요.

### 2-1. 코드 사전 점검 (Pre-Flight Check)

Vercel에 올리기 전에 내 컴퓨터에서 먼저 확인하는 습관을 들이세요.

1.  **환경 변수 로딩 확인**:
    - `src/services/supabase.ts` 파일에서 `createClient()`가 환경 변수 없이 호출되면 앱이 뻗습니다.
    - 안전 장치(`|| ''` 같은 fallback 코드)가 되어 있는지 확인하세요.
2.  **널 체크 (Null Safety)**:
    - `lastCompletedBooking!.id` 와 같이 `!` 기호를 남발하면 데이터가 없을 때 100% 에러 납니다.
    - 항상 `lastCompletedBooking?.id` 처럼 물음표(`?`)를 사용하거나 `if`문으로 감싸주세요.
3.  **빌드 테스트**:
    - `npm run build` 명령어를 쳐보세요.
    - 여기서 에러가 나면 Vercel에서도 100% 에러 납니다.

### 2-2. Vercel 배포 및 재배포

1.  **자동 배포**:
    - 코드를 수정하고 `git push`를 하면 Vercel이 자동으로 감지하고 새 버전을 만듭니다.
2.  **환경 변수 수정 시**:
    - Vercel 대시보드에서 `Environment Variables`를 수정했다면, **반드시 재배포(Redeploy)** 해야 적용됩니다.
    - _버튼을 못 찾겠다면?_: 터미널에 `git commit --allow-empty -m "trigger redeploy" && git push` 입력.

---

## ☁️ 3. 데이터베이스 (Supabase) 가이드

데이터가 안 보이거나 저장이 안 될 때 확인하세요.

1.  **RLS 정책 (Row Level Security)**:
    - Supabase는 기본적으로 "아무도 못 보게(Deny All)" 설정되어 있습니다.
    - `Table Editor` -> `bookings` 테이블 -> `Add RLS Policy` 에서 `Enable Read Access for everyone`과 `Enable Insert for everyone`을 추가해야 합니다.
2.  **날짜 형식**:
    - 캘린더 날짜가 하루씩 밀리는 현상은 타임존 때문입니다.
    - DB에는 `Timestamp` 대신 그냥 `Text` 형식으로 `'2026-02-01'` 처럼 저장하는 것이 가장 안전합니다.

## 🔧 4. Antigravity AI 설정 (다른 PC에서 AI 쓰려면)

이 프로젝트를 도와준 AI(Antigravity)를 다른 PC에서도 쓰려면:

1.  프로젝트 루트의 `.agent` 폴더를 그대로 가져가세요.
2.  사용자 폴더(`C:\Users\사용자명\.gemini\antigravity\mcp_config.json`) 설정을 확인하세요.

---

**유지보수 문의**: GitHub Issue 탭을 활용하거나 개발자에게 문의하세요.
