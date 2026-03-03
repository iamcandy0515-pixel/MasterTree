# 🏗️ Technical Stack & Engineering Standards (TECH_STACK.md)

> **Authority (권한)**: 이 문서는 엔지니어링 의사결정의 유일한 진실 공급원(Single Source of Truth)입니다.
> **Enforcement (강제성)**: 모든 PR(Pull Request)과 아키텍처 결정은 반드시 이 규칙을 따라야 합니다.

---

## 1. 🛠️ Core Technology Stack (핵심 기술 스택)

### 1.1 Development Environment (Windows OS Mandatory)

- **Operating System**: `Windows` (Unix/Linux 명령어는 WSL 환경이 아닌 이상 **사용 금지**).
- **Shell**: `PowerShell` 또는 `CMD` (`bash` 스크립트 직접 사용 금지).
- **Rule**: 모든 스크립트(package.json, 자동화 등)는 반드시 Windows와 호환되어야 합니다.
    - ❌ `rm -rf`
    - ✅ `rimraf` 또는 `Remove-Item`
    - ❌ `export VAR=val`
    - ✅ `set VAR=val` (cmd) 또는 `$env:VAR='val'` (pwsh) 또는 `cross-env`

### 1.2 Backend System (Node.js API)

- **Runtime**: `Node.js v18+` (LTS 버전 필수)
- **Language**: `TypeScript v5.x` (Strict Mode 활성화)
- **Framework**: `Express` (표준 REST 패턴)
- **Database**: `Supabase` (PostgreSQL)
- **AI Engine**: `Google Gemini 1.5 Pro` (`@google/generative-ai` 사용)
- **Package Manager**: `npm` (Turborepo 사용)

### 1.3 Frontend System (Mobile Applications)

- **Framework**: `Flutter` (Channel: Stable)
- **Language**: `Dart` (SDK 제약: `^3.10.7`)
- **Apps**:
    - `flutter_admin_app`: 내부 관리용 도구
    - `flutter_user_app`: 일반 사용자용 앱
- **State Management**: _미정 (Riverpod 권장 - Clean Code 규칙 준수)_

---

## 2. 🧱 Architecture Standards (아키텍처 표준)

### 2.1 Monorepo Structure & Lightweight Strategy

**목적(Purpose)**: 단일 앱의 비대함을 방지하고 **모듈 경량화(Lightweight)**를 실현하기 위해, 역할을 3개의 독립된 프로젝트로 분리하여 운영합니다.

```
/
├── nodejs_admin_api/     # [Backend] 데이터 처리 및 무거운 비즈니스 로직 전담 (Source of Truth)
│   └── src/
│       ├── modules/      # 기능 기반 모듈
│       ├── controllers/  # 요청 처리 (Thin layer)
│       └── services/     # 비즈니스 로직 (Fat layer)
├── flutter_admin_app/    # [Frontend] 관리자 기능 전용 UI (Thin Client)
└── flutter_user_app/     # [Frontend] 사용자 기능 전용 UI (Thin Client)
```

**핵심 전략 (Core Strategy)**:

- **Thin Client 원칙**: `flutter_admin_app`은 데이터 가공을 최소화하고 화면 표시에 집중합니다.
- **Heavy Lifting**: 복잡한 통계 계산, 대용량 데이터 처리, 이미지 분석 등 무거운 로직은 반드시 **`nodejs_admin_api`**가 전담합니다.

### 2.2 Backend Rules (API)

1.  **Modular Pattern**: 모든 기능은 반드시 `src/modules/{featureName}` 안에 위치해야 합니다.
2.  **Controller Responsibility**: 오직 요청/응답 파싱만 담당합니다. 비즈니스 로직 포함 **금지**.
3.  **Service Responsibility**: 로직 처리, DB 호출, 외부 API 통신을 담당합니다.
4.  **Error Handling**: 전역 에러 미들웨어를 사용하세요. 빈 `catch` 블록 사용 금지.
5.  **Environment Variables**: 시작 시 `dotenv`를 통해 반드시 유효성 검사를 해야 합니다.

### 2.3 Frontend Rules (Flutter)

1.  **Dart Version**: 엄격하게 `>=3.10.7 <4.0.0` 범위를 유지하세요.
2.  **Linting**: `flutter_lints` v6.0.0 필수 적용. 경고(Warning) 0개 정책.
3.  **Supabase Client**: Auth/Data 처리를 위해 싱글톤(Singleton) 패턴을 사용하세요.
4.  **Design System**:
    - **색상 하드코딩 금지**: 반드시 `STYLE_GUIDE.md`의 명명된 상수(Named Constants)를 사용하세요.
    - **일회성 스타일 금지**: 표준 UI 요소를 위한 재사용 가능한 위젯을 만드세요.
5.  **UI & Logic Separation (UI/로직 분리 - Mandatory)**:
    - **원칙**: 앱의 경량화를 위해 UI 위젯은 오직 **화면 렌더링**과 **이벤트 전달**만 담당해야 합니다.
    - **제약**: `Screen`이나 `Widget` 파일 내에 복잡한 데이터 처리, 조건문 분기, 비즈니스 로직이 포함되면 **승인 거부(Reject)** 됩니다.
    - **구현**: 모든 로직은 반드시 **ViewModel** 또는 **Service** 계층으로 분리하여 호출해야 합니다.

---

## 3. ⛔ Restricted & Banned Technologies (제한 및 금지 기술)

| Technology      | Status                | Reason                         | Replacement                        |
| :-------------- | :-------------------- | :----------------------------- | :--------------------------------- |
| **GetX**        | ⛔ **BANNED (금지)**  | 아키텍처 저품질, 테스트 어려움 | `Riverpod` 또는 `Provider`         |
| **TailwindCSS** | ⚠️ **CAUTION (주의)** | Flutter 표준 아님; JS 전용     | 로직 기반 스타일 / Stylesheet 패턴 |
| **Any (`any`)** | ⛔ **BANNED (금지)**  | TypeScript 사용 목적 상실      | `unknown` 또는 구체적 Interface    |
| **console.log** | ⚠️ **WARN (경고)**    | 프로덕션 로그 오염             | 커스텀 `Logger` 서비스 사용        |

---

## 4. 🎨 Design System Synchronization (디자인 시스템 동기화)

_시각적 정의는 `STYLE_GUIDE.md`를 참고하세요._

- **Theme Name**: `Neo-Nature`
- **Primary Color**: Acid Lime (`#CCFF00`)
- **Background**: Void Green (`#020402`)
- **Typography**: Inter (본문), Space Grotesk (헤더)

---

## 5. 🔄 Workflow & Version Control (워크플로우 및 버전 관리)

1.  **Branching**: `feat/`, `fix/`, `chore/` 접두어 사용 필수.
2.  **Commits**: Conventional Commits 준수 (예: `feat: add tree upload endpoint`).
3.  **Pre-Flight (배포 전 점검)**:
    - Backend: `npm run dev` (API 정상 확인)
    - Mobile: `flutter analyze` (정적 분석 통과 확인)

---
