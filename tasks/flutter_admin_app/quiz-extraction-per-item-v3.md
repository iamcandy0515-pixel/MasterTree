# Task: 기출문제 추출(건별) 고도화 (데이터 부재 처리 포함)

## 1. ANALYSIS (연구 및 분석)

- **Objective**: '기출문제 추출(건별)' 화면의 안정성을 높이고, 추출 결과가 없을 때 임의 데이터를 생성하지 않고 사용자에게 명확한 메시지를 전달함.
- **Key Changes**:
    - 추출 실패 및 데이터 부재 처리: `extractBatch` 결과가 비어있을 경우 "추출할 문제가 없습니다" 메시지 출력.
    - 단일 문제 추출 로직 고도화: 1~15번 콤보박스 선택에 따른 타겟 넘버 추출.
    - UI 일관성 유지: 범위 제거 및 단건 UI 구성.

## 2. PLANNING (작업 단계별 계획)

### 1단계: ViewModel 추출 데이터 검증 로직 강화

- `startBatchExtractionAction` 내부에서 `extractedCount`가 0일 경우에 대한 예외 처리 루틴 추가.
- API 응답이 성공하더라도 실제 문제 데이터(blocks)가 유효하지 않거나 비어있으면 사용자에게 경고 메시지 전달.
- AI 임의 생성 방지: 백엔드 호출 결과 기반으로만 데이터를 로드하도록 보장.

### 2단계: 헤더 및 화면 연동 (Review)

- '문제번호' 선택 시와 'PDF 추출' 버튼 클릭 시의 동작 일치 여부 재검토.
- 추출 성공/실패에 따른 Floating Message(Toast) 연동 강화.

### 3단계: 통합 테스트 및 품질 검증

- 존재하지 않는 파일 ID나 범위를 벗어난 번호 선택 시 적절한 에러 메시지가 출력되는지 확인.
- `flutter build web` 수행 후 런타임 오류(Index Error 등)가 완전히 해결되었는지 체크.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Error Feedback Policy**: 시스템 오류가 아닌 "데이터 없음"은 단순 경고(Warning) 아이콘과 함께 안내하여 사용자 혼란 방지.
- **Data Integrity**: 추출된 데이터가 없을 경우 현재 편집 중인 `currentQuiz` 상태를 유지하거나 클리어하여 이전 데이터가 섞이지 않도록 관리.

## 4. IMPLEMENTATION (구현 계획)

- [ ] ViewModel: `extractedCount == 0` 체크 로직 추가 및 메시지 분기 처리.
- [ ] UI/Header: 문제번호 콤보박스 및 추출 버튼 연동 최종 점검.
- [ ] Bug Fix: `HintModule` 등 하위 모듈의 데이터 바인딩 안정성 강화.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **Risk**: 백엔드에서 빈 배열을 보낼 때의 형식이 일관되지 않을 수 있음 (Check `item['content_blocks']` existence).
- **Check**: 번호 자동 증가 후 다음 번호가 데이터가 없는 상태일 때, '추출되지 않음'을 인지할 수 있는 UI 상태(Empty State) 확인.
