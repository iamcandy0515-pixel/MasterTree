# 기출문제 일람의 조회 조건 레이아웃 및 카드 표기 개선 (quiz-management-ui-layout-fix)

## 1. 목적 및 범위 (Plan)

- **목적:**
    1. '기출문제 일람' 화면의 조회 필터 영역에 있는 배경색(`surfaceDark`)을 삭제하고, '저장' 버튼을 제거하여 상단 영역을 시각적으로 가볍게 정리한다.
    2. 조회 조건 콤보박스들(과목, 년도, 회차) 바로 앞에 "조회 조건"이라는 텍스트 시각적 가이드를 추가한다.
    3. 기출문제 카드 내부 본문 텍스트가 너무 긴 경우 2줄에서 말줄임말(...)이 되던 기존 방식을 더욱 강제하여 **1줄(`maxLines: 1`)**에서 바로 잘리도록 제한하여 전체 리스트의 세로 폭(가독성)을 균일하게 맞춘다.
    4. 이전 업데이트에서 파생된 코드 린트 경고(사용하지 않는 `_quizData` 필드 및 인스턴스 문자열 내 변수 매핑 오류 `\$`)를 완전히 해결하여 앱 빌드 안정성을 높인다.
- **범위:**
    - `flutter_admin_app/lib/features/quiz_management/screens/quiz_management_screen.dart`
    - `flutter_admin_app/lib/features/quiz_management/screens/quiz_review_detail_screen.dart`

## 2. 작업 내용 (Execute)

- **조회 영역 배경색 및 버튼 정리 (`quiz_management_screen.dart`):**
    - 기존에 `color: surfaceDark`로 덮여있던 필터 영역 최상위 Container의 배경 스플래시를 지움. (스크린과 같은 `backgroundDark` 테마로 투명하게 융화됨)
    - 영역 최하단 우측에 있던 `TextButton('저장')`을 코드에서 영구 삭제하였으며, 좌측의 '신규등록' 버튼만 유지.
- **조회 조건 라벨 추가:**
    - `Wrap` 위젯 내부에 `crossAxisAlignment: WrapCrossAlignment.center` 속성을 주어 텍스트와 콤보박스의 높낮이 중앙을 맞춤.
    - 최상단 첫 번째 자식으로 `const Text('조회 조건')`을 추가.
- **카드 본문 1줄 제한:**
    - `_buildQuizTextCard` 내 `Expanded(child: Text(...))` 부분의 `maxLines: 2`를 **`maxLines: 1`**로 수정. 카드의 세로 높이가 대폭 줄어들었음.
- **잔여 버그 픽스 (`quiz_review_detail_screen.dart`):**
    - Dart 언어의 `Text('$_year년')` 보간법(String Interpolation)에서 백슬래시(`\`)가 들어가 변수가 인식되지 않던 현상을 정정함.
    - 불필요하게 선언되고 캐싱되던 `_quizData` 변수 선언 및 할당부 소거하여 컴파일러 Warning(lint) 제거.

## 3. 사후 점검 (Review)

- **Result (완료된 결과):** 기출문제 조회 영역의 배경과 거추장스러운 버튼이 사라지고 "조회 조건" 타이틀이 눈에 띄게 배치되어 UX가 명확해짐. 카드 리스트에서도 문제가 한 줄로 깔끔하게 떨어지게 되어, 한 화면에 더 많은 문제를 스크롤 없이 볼 수 있게 됨.
- **Risk Analysis (향후 문제점 및 리스크 분석):** 문제 내용이 단 1줄로 표시되기 때문에 복잡한 지문이나 앞부분에 "[기출] 다음과 같은 특징을 가진 수종으로 적합한..." 등 서론이 긴 문제는 카드 목록에서 식별하기 어려워짐. 그러나 카드를 클릭해 검수 화면에 들어가면 전체 본문(Max 3 lines 이상)을 스크롤하여 상세 파악이 가능하므로 의도하신 바에 부합함.
