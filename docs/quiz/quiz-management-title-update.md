# 현재 작업 현황

## [1] 작업 계획

- 목표:
    1. 기출문제 퀴즈 관리 화면 상단 좌측의 타이틀을 '기출문제 퀴즈 검수'에서 '기출문제 일람'으로 변경.
    2. 더 이상 필요하지 않은 우측 하단의 구글 드라이브 스캔 용도의 Floating Action Button (플로팅 아이콘) 삭제.
- 범위:
    - `flutter_admin_app/lib/features/quiz_management/screens/quiz_management_screen.dart`

## [2] 세부 작업 내용

- [x] `quiz-management-title-update.md` 파일 생성
- [x] `quiz_management_screen.dart`에서 AppBar 타이틀의 텍스트를 '기출문제 퀴즈 검수' -> '기출문제 일람'으로 수정.
- [x] `Scaffold` 내부 하단에 선언되었던 `floatingActionButton` UI 위젯 프로퍼티 및 내용물 전체 삭제.

## [3] 결과 분석 및 위험 요인

- **결과 (Result):**
    - 명칭이 스크린의 실제 기능(검수 대기중인 것만 보는 것이 아닌 모든 문제의 목록을 보는 화면)에 맞추어 `기출문제 일람`으로 보다 일치성 높게 변경됨.
    - 쓰이지 않던 기능의 Floating Action Button이 삭제되어 화면이 훨씬 정리됨.
- **리스크 분석 (Risk Analysis):**
    - 우측 하단에서 스캔을 시작해 주는 기능이 완전히 사라지게 되었으나, 이 기능은 별도의 `기출문제 연동` (퀴즈 추출 2단계 페이지) 화면 등에서 기능을 수행하고 있으므로 현재 화면에서의 제거로 인한 치명적인 사용자 흐름(Flow) 손실은 없습니다. 화면 공간 확보 및 오작동 가능성을 차단할 수 있습니다.
