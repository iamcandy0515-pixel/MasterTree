# [Plan] 사용자 대시보드 내비게이션 안정화 및 뒤로가기 제어

이 계획서는 사용자 대시보드 진입 후 뒤로가기 버튼이 의도한 대로 동작하지 않는 현상을 해결하고, 프리미엄한 사용자 경험(UX)을 제공하기 위한 단계별 구현 방안을 담고 있습니다.

## 1. 개요
현재 `AuthWrapper`를 통한 반응형 화면 전환 방식과 `LoginScreen`에서의 명시적 `Navigator.pushReplacement` 방식이 혼용되어 네비게이션 스택이 꼬이는 문제가 발생하고 있습니다. 이를 정리하고 대시보드에서의 뒤로가기 동작을 명확히 정의합니다.

## 2. 작업 단계 (Implementation Steps)

### 1단계: 중복 내비게이션 제거 (Navigation Cleansing)
- **대상**: `lib/screens/login_screen.dart`
- **목적**: `Navigator.pushReplacement` 호출을 제거하여 `AuthWrapper`가 단일 소유자로서 화면 전환을 관리하게 함.
- **예상 결과**: 로그인 성공 시 인증 상태 변화만으로 대시보드에 진입하며, 불필요한 네비게이션 스택 생성을 방지함.

### 2단계: 뒤로가기 핸들러 구현 (Back Button Controller)
- **대상**: `lib/screens/dashboard_screen.dart`
- **목적**: 대시보드 최상위 위젯을 `WillPopScope`로 감싸 시스템 뒤로가기 이벤트를 가로챔.
- **예상 결과**: 뒤로가기 버튼 클릭 시 무시되거나 특정 동작(팝업 등)이 실행되도록 제어권 확보.

### 3단계: 로그아웃 확인 UI 고도화 (Premium Exit UX)
- **대상**: `lib/screens/dashboard_screen.dart` 내 `onWillPop` 로직
- **목적**: 뒤로가기 시 바로 종료되는 대신, "로그아웃" 또는 "종료" 여부를 묻는 디자인 시스템 기반의 다이얼로그 제공.
- **예상 결과**: 사용자가 실수로 앱을 종료하는 것을 방지하고, 명확한 퇴장 경로 제공.

## 3. 기술적 상세 (Technical Details)
- **WillPopScope 활용**: `onWillPop: () => _showExitDialog(context)` 형태의 핸들러 연결.
- **Design System 준수**: `AppColors` 및 `standard shape`를 적용한 프리미엄 다이얼로그 구현.

## 4. 리스크 관리
- **BOM 이슈**: PowerShell `Set-Content` 대신 안정적인 도구를 우선 사용하여 파일 인코딩 문제를 원천 차단함.
- **상태 동기화**: `AuthViewModel`의 `signOut` 메서드와 연동하여 세션 정리를 보장함.
