# 통합 뒤로가기 버튼(‘<’) UI 통일 작업 계획 (Unified Back Button Plan)

## 📌 목표 (Plan)

Flutter 사용자 앱(`flutter_user_app`)과 관리자 앱(`flutter_admin_app`)에 존재하는 모든 화면의 뒤로가기 및 닫기 버튼 모양을 `'<'` (즉, `Icons.arrow_back_ios_new`) 아이콘으로 완벽하게 일관성을 갖도록 통일합니다. 이를 통해 OS(Android/iOS)에 관계없이 앱 전체에서 동일한 사용자 경험(UX)과 깨끗한 UI 규칙을 제공합니다.

## 🛠 작업 범위 및 세부 변경(Execution Steps)

### 1단계: 글로벌 테마(ThemeData)를 활용한 전역 통일

각 앱의 루트(`main.dart` 또는 `design_system.dart` 내부 ThemeData 설정 등)에서 기본 `ActionIconThemeData` 또는 `AppBarTheme`를 전역적으로 재정의합니다.

- **적용:** Flutter 프레임워크가 제공하는 기본 AppBar 뒤로가기 버튼 요소(`BackButton`)가 안드로이드용 기본(←) 화살표를 쓰지 않고 무조건 `<`(`Icons.arrow_back_ios_new`)가 나오도록 덮어씌웁니다.

### 2단계: 하드코딩된 `leading: IconButton` 걷어내기 (코드 경량화)

- **현황 분석:** 현재 여러 화면(`quiz_review_detail_screen`, `past_exam_detail_screen`, `tree_list_screen` 등)의 `AppBar`에 수동으로 `leading: IconButton(icon: Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context))` 형태의 코드가 분산 작성되어 있습니다.
- **조치 방법:** 이렇게 단순히 이전 화면으로 돌아가는 역할을 수행하는 하드코딩된 `leading` 위젯 코드를 프로젝트 전반에서 일괄 제거합니다. 1단계에서 전역 설정한 기본 `BackButton`이 자연스럽게 활성화되어 코드가 훨씬 가벼워지며 화면마다 버튼 사이즈나 여백이 미세하게 틀어지는 현상을 방지합니다.

### 3단계: 화면/모달별 `Icons.close` (닫기) 아이콘 일괄 변경

- **현황 분석:** `bulk_similar_management_screen` 등 일부 모달 또는 Full Screen Dialog 형태로 띄워지는 화면들의 `AppBar`에는 `Icons.close`('X' 표시) 아이콘이 하드코딩 되어 있습니다.
- **조치 방법:** 모달 화면이든 일반 화면이든 관계없이 모든 화면에서 뒤로가기 동작의 메타포를 `'<'` 로 통일해 달라는 요구사항에 맞춰, 기존의 `Icons.close` 아이콘들을 모두 제거하거나 `Icons.arrow_back_ios_new`로 교체합니다.

## ⚠️ 리스크 분석 (Risk Analysis)

- **뒤로가기 시 데이터 소실 가능성**: 뒤로가기를 할 때 경고 모달 창(`정말 나가시겠습니까?`)이 필요하여 `WillPopScope` 나 커스텀 `onPressed` 콜백이 연결된 화면(예: 복잡한 폼 입력, 시험 주관식 풀이 중단 등)에서는 `leading` 설정을 무작정 제거하면 경고창 로직이 무시될 우려가 있습니다.
    - **완화 방안:** 커스텀 동작이 필요한 화면의 하드코딩된 `leading`은 지우지 않고, 아이콘 모양만 `Icons.arrow_back_ios_new`로 명시적으로 덮어쓰고 나머지는 그대로 유지하도록 선별 작업합니다.

이러한 로직 규칙을 바탕으로 전역 작업(모든 화면)을 진행해도 괜찮으시다면 승인해주시면 되며, 확인되는 즉시 두 앱의 전체 파일 교체 작업을 수행하겠습니다!
