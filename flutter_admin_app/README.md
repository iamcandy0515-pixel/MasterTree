# Flutter Admin App Dashboard

This project is the admin dashboard for the MasterTreeApp.

## 🚨 [필독] 개발 및 테스트 가이드 (Mandatory Rules)

아래 규칙은 모든 개발자가 반드시 준수해야 합니다.

### 1. 웹 브라우저 테스트 및 연결 규칙

- **현상**: `flutter run -d chrome`으로 실행된 브라우저 창을 닫으면 디버그 세션이 종료됩니다.
- **오류 메시지**: 이후 같은 포트(예: 8081)로 접속 시 `ERR_CONNECTION_REFUSED` 에러가 발생합니다.
- **해결법**: 브라우저를 닫았다면 반드시 `flutter run` 명령어로 서버를 **재시작**해야 합니다.
    - **Tip**: 브라우저를 닫지 않고 `R` (Hot Restart) 또는 `r` (Hot Reload)을 사용하여 테스트하세요.

### 2. 이미지 업로드/캡처 기능 구현 표준

새로운 이미지 업로드 기능을 구현할 때는 반드시 **3가지 방식**을 모두 지원해야 합니다:

1. **클릭 업로드**: 파일 탐색기를 통한 선택
2. **드래그 앤 드롭**: `dart:html`과 `HtmlElementView`를 사용하여 네이티브 드롭존 구현
3. **캡처 붙여넣기 (Ctrl+V)**: `window.navigator.clipboard` API를 사용하여 캡처된 이미지 지원

### 3. Flutter Web API 사용 규칙 (Flutter 3.10+)

- **금지**: `import 'dart:ui' as ui;` 및 `ui.platformViewRegistry` 사용 금지 (컴파일 에러 발생)
- **필수**: `import 'dart:ui_web' as ui_web;` 사용 및 `ui_web.platformViewRegistry` 사용

### 4. 서버 실행 구조 (Dual Server System)

관리자 시스템은 **항상 2개의 서버**가 실행 중이어야 합니다.

| 순서  |    시스템    | 경로                | 명령어                     | 역할                                |
| :---: | :----------: | :------------------ | :------------------------- | :---------------------------------- |
| **1** | **Backend**  | `nodejs_admin_api`  | `npm run dev`              | 데이터 처리 및 API 제공 (Port 3000) |
| **2** | **Frontend** | `flutter_admin_app` | `flutter run -d chrome...` | 관리자 웹 UI 표시 (Port 8081)       |

> **Note**: 백엔드가 실행되지 않으면 프론트엔드에서 데이터 로딩 오류가 발생합니다.

---

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
