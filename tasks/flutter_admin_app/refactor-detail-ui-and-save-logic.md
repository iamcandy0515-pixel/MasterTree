# Task: 수목일람 상세 UI 슬림화 및 저장 로직 고도화

## 상태 기록 (Plan)

- **목적**: 상세 화면의 시각적 요소 간소화로 정보 가독성 증대 및 데이터 저장 구조 정교화
- **분석 및 개선 포인트**:
    1. **AppBar & Header**:
        - 제목: '수목 이미지 상세' -> '수목일람 상세' 변경
        - 삭제 아이콘(휴지통) 제거 (실수 방지 및 UI 정리)
        - 상단 수목명(아이콘 포함) 섹션 제거 (AppBar 제목으로 대체)
    2. **레이아웃 간소화**:
        - '기본 정보' 섹션의 박스 배경(Container decoration) 및 테두리 제거
        - 상하 간격(SizedBox, Padding) 축소로 스크롤 없이 더 많은 정보 노출
    3. **데이터 저장 로직 (DB저장)**:
        - 부위별(대표, 수피, 잎, 꽃, 열매) '이미지 URL'과 '힌트(설명)' 정보를 개별 객체로 분리하여 전송
        - 퀴즈 오답(Distractors) 리스트와 통합하여 API 요청 수행
- **대상 파일**:
    - `lib/features/trees/screens/tree_detail_screen.dart`
    - `lib/features/trees/repositories/tree_repository.dart` (필요 시)

## 실행 (Execute)

1. **상단 UI 및 AppBar 정리**
    - [x] AppBar 제목 수정 ('수목일람 상세') 및 `actions`에서 `IconButton(delete)` 제거
    - [x] `build` 메서드 내 중복 수목명 표시 섹션 삭제
2. **기본 정보 폼(Form) 슬림화**
    - [x] `_buildBasicInfoForm`의 `Container` 배경 및 테두리 제거 (padding: zero)
    - [x] `Divider` 및 `SizedBox` 간격 대폭 축소 (12~16px 수준)
3. **DB 저장 로직 개편**
    - [x] `_saveAll` 메서드 내에서 이미지 정보와 힌트의 쌍(TreeImage object) 전송 구조 확인
    - [x] 퀴즈 오답 데이터 포함 상태로 API 요청 수행 및 저장 프로세스 유지
4. [x] 최종 레이아웃 검토 및 사용되지 않는 `_deleteTree` 메서드 삭제 완료 (Lint 대응)

## 사후 점검 (Review)

- **완료된 결과 (Result)**:
    - 상세 화면의 정보 집약도가 높아져 스크롤 없이 주요 정보 편집 가능.
    - 불필요한 UI 장식 제거로 더 깨끗한 관리자 UI 구현.
    - 삭제 버튼 제거로 중요한 수목 데이터 보존 안정성 강화.
- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - 배경색 제거로 인해 입력 필드 간의 경계가 모호해 보일 수 있으므로 사용자 피드백 확인 필요.
    - 삭제 기능이 필요한 경우를 대비해 목록 화면의 스와이프 액션 등으로 대체 가능성 열어둠.
