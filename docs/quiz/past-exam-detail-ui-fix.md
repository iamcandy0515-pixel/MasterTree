# Task: 기출문제 상세 화면 UI 조정 (테두리 제거 및 간격 최적화)

## 상태 기록 (Plan)

- **목적**: 기출문제 상세 화면(`PastExamDetailScreen`)의 시인성을 높이기 위해 입출력 필드의 테두리를 제거하고 세로 간격을 조정하여 한눈에 들어오도록 개선.
- **주요 수정 사항**:
    1. `_buildInfoBanner`, `_buildDisplayBox`, `_buildOptionsList`에서 `border` 속성 제거.
    2. 섹션 간 간격(`SizedBox(height: 24)`) 축소.
    3. 각 박스의 내부 여백(`padding`) 및 섹션 타이틀 하단 여백 축소.
    4. 문제 보기 아이템 간의 간격(`margin`) 축소.

## 실행 (Execute)

1. `lib/screens/past_exam_detail_screen.dart` 수정:
    - `_buildInfoBanner`의 테두리 제거.
    - `_buildSectionTitle`의 하단 여백 축소 (12 -> 6).
    - `_buildDisplayBox`의 테두리 제거 및 패딩 축소 (16 -> 12).
    - `_buildOptionsList`의 테두리 제거, 패딩 축소 (16 -> 10), 마진 축소 (8 -> 4).
    - 메인 `Column` 내의 섹션 간 간격 축소 (24 -> 16).

## 사후 점검 (Review)

- **완료된 결과 (Result)**: (작업 완료 후 작성)
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - 테두리가 없어짐에 따라 배경색(`AppColors.surfaceDark`)과 전체 배경색(`AppColors.backgroundDark`) 간의 대비가 충분하지 않을 경우 구분이 모호해질 수 있음. (현재 구분은 가능할 것으로 판단됨)
    - 간격이 너무 좁아질 경우 텍스트가 밀집되어 보일 수 있으므로 적절한 수치 조정 필요.
