# Task: Fix Port Mismatch and UI Overflow

## 상태 기록 (Plan)

- **목적**: API 포트 불일치 해결 및 관리자 앱 상세 화면의 오버플로 버그 수정
- **분석**:
    - API 포트: 현재 3000 기동 -> 앱은 4000 요청 중
    - UI 오버플로: `tree_detail_screen.dart:502` Row 위젯 42px 초과
- **해결 방안**:
    1. API 포트를 4000으로 변경하여 재기동
    2. `tree_detail_screen.dart` 오버플로 위젯 수선

## 실행 (Execute)

1. [x] Node.js API `PORT=4000` 설정 확인 완료 (이미 4000으로 기동 중)
2. [x] `tree_repository.dart`: 엔드포인트 경로에 `/service` 추가 완료 (404 해결)
3. [x] `tree_detail_screen.dart:502`: Row 위젯 오버플로 방지를 위해 Expanded/Flexible 적용 완료

## 사후 점검 (Review)

- **완료된 결과 (Result)**: 404 API 오류 및 UI 오버플로 해결 완료.
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - 앱 전체에서 엔드포인트 누락 여부 추가 확인 필요.
    - 좁은 화면에서 헤더 텍스트 생략 시 사용자가 전체 내용을 확인하기 어려울 수 있음.
