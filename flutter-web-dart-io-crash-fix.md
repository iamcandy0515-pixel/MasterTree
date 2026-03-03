# 브라우저 기동 실패(White Screen) 이슈 핫픽스 (dart:io 의존성 제거)

## 1. 목적 및 범위 (Plan)

- **증상:** `quiz_management_screen.dart`에서 `NodeApi`를 최초로 사용하도록 수정한 직후부터, 웹(Chrome/Edge) 환경에서 로컬 `http://localhost:8081` 접속 시 아예 초기화도 되지 않고 하얀 화면이 뜨며 앱이 기동되지 않는 크래시(Crash) 발생.
- **원인 분석:**
    - `NodeApi` 파일(`node_api.dart`) 상단에 기존부터 `import 'dart:io';` 구문과 로컬 폴더 경로 `File`을 인자로 받는 더미 함수(`uploadImage`)가 잔존해 있었음.
    - 기존에는 `NodeApi`가 프로젝트 어디서도 사용되지 않는 '죽은 코드(Dead Code)'였기 때문에 Flutter 빌드 시 트리 쉐이킹(Tree Shaking)되어 런타임 오류가 없었음.
    - 그러나 직전 작업에서 보안처리를 위해 `node_api.dart`를 호출하게 되자, 앱 전체 의존성에 `dart:io`가 편입됨.
    - Flutter Web은 OS 직접 접근을 금지하므로, `dart:io`의 File 클래스 등이 평가되는 순간 브라우저 단에서 즉각적인 **Unsupported operation (지원되지 않는 작업) 런타임 크래시** 창출.
- **조치 목표:** `flutter_admin_app/lib/core/api/node_api.dart`에서 Web 호환성을 깨트리는 `dart:io` 및 미사용 함수들을 완벽히 도려내어 정상 부트 복구.

## 2. 작업 내용 (Execute)

- **Web 컴파일 충돌 요소 완전 제거:**
    - `node_api.dart` 최상단의 `import 'dart:io';` 임포트 라인 삭제.
    - 더 이상 사용되지 않는 과거 버전의 `uploadImage(File file)` 함수 몸체 삭제 (대신 최신 코드인 `TreeRepository` 내의 `XFile` 기반 `uploadImage` 가 올바르게 파일 업로드를 책임지고 있음).
- **포트 충돌 완화:**
    - 기존에 어설프게 백그라운드에 남아있어 8081 포트와 3000 포트를 점유하던 고아 프로세스(`dartvm`, `node.exe`)들을 `Stop-Process -Force` 및 `taskkill`로 완벽 척결.
    - `npx turbo run dev`를 재시작하여 쾌적한 환경 구성.

## 3. 사후 점검 (Review)

- **Result:** 에러의 근원(dart:io 기반 API 연동 함수)이 제거되었으므로 더 이상 브라우저 최초 기동 시 빈 화면으로 크래시가 터지지 않게 되었습니다. 정상적으로 Login 및 8081 포트를 통해 관리자 UI를 볼 수 있습니다.
- **Risk Analysis:**
    - 앞으로 Flutter Admin과 같은 웹 베이스의 앱을 개발할 때는 절대 `dart:io`의 `File` 모델을 사용하면 안 되며, 파일 업로드 시에는 반드시 `cross_file` 패키지의 `XFile`이나 `dart:typed_data`의 `Uint8List`(바이트 체계)를 통해서 통신해야 한다는 점을 아키텍처 가이드라인으로 상기해야 합니다.
