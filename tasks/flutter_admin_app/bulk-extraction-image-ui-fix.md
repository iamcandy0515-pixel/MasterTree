# Task: PDF 일괄추출 이미지 관리/보기 UI 이원화 및 최적화

## 1. 개요 (Overview)

관리자 앱의 PDF 일괄 추출 화면에서 '문제' 및 '해설' 섹션의 이미지 처리 UI를 개선합니다. 이미지가 있을 때와 없을 때를 구분하여 사용자에게 가장 필요한 기능을 우선적으로 노출하는 '기능 이원화'를 목표로 합니다.

## 2. 작업 범위 (Scope)

- **대상 화면**: `QuizExtractionStep2Screen` 내 `QuestionExplanationModule`
- **핵심 UI 변경**:
    - **이미지 존재 시**: [이미지 보기] (즉시 확인) + [이미지 관리] (추가/삭제) 2개 버튼 노출
    - **이미지 부재 시**: [이미지 관리] (이미지 추가용) 1개 버튼만 노출
- **적용 대상**: '문제 내용', '해설 내용' 두 섹션 모두 동일하게 적용

## 3. 상세 단계 (Plan)

### Phase 1: ViewModel 기능 확장

- [ ] `QuizExtractionStep2ViewModel`에 특정 필드('question', 'explanation')의 첫 번째 이미지 URL을 반환하는 유틸리티 메서드 `getFirstImageUrl(field)` 추가

### Phase 2: 핵심 모듈 UI 개편 (`QuestionExplanationModule.dart`)

- [ ] `_buildEditFieldWithImages` 메서드 수정:
    - `vm.hasImage(field)` 조건을 확인하여 버튼 레이아웃 분기 처리
    - **[이미지 보기] 버튼**:
        - 아이콘: `Icons.visibility` 또는 `Icons.remove_red_eye`
        - 동작: 다이얼로그 없이 즉시 `FullscreenImageViewer` 호출 (첫 번째 이미지 대상)
    - **[이미지 관리] 버튼**:
        - 아이콘: `Icons.image` 또는 `Icons.settings`
        - 동작: 기존 `SingleQuizImageManagerDialog` 오픈
    - **이미지 없을 때**:
        - 텍스트를 '이미지 추가'로 명확히 표시하고 1개만 노출

### Phase 3: 이미지 뷰어 연동 및 스타일 최적화

- [ ] 기구현된 '원본 크기 뷰어'(`FullscreenImageViewer`)가 두 버튼(보기, 상세관리 내 미리보기)에서 모두 완벽하게 작동하는지 재검증
- [ ] 사용자 앱 패턴을 이식하여 버튼 간 간격(spacing) 및 시각적 위계(Primary Color 활용) 조정

## 4. 검증 항목 (Verification)

- [ ] 이미지가 없는 상태에서 '이미지 관리' 버튼 1개만 보이는가?
- [ ] 이미지 업로드 후 즉시 '이미지 보기'와 '이미지 관리' 2개 버튼으로 바뀌는가?
- [ ] '이미지 보기' 클릭 시 관리 화면을 거치지 않고 다이렉트로 원본 사진이 뜨는가?
- [ ] '문제'와 '해설' 섹션 모두 동일한 규칙으로 작동하는가?

---

## 사후 점검 (Review)

_(작업 완료 후 작성 예정)_

## Risk Analysis

- 한 섹션에 이미지가 여러 개일 경우 '이미지 보기' 버튼이 어떤 이미지를 보여줄지 정의 필요 (기본값: 첫 번째 이미지). 상세한 전수 조사는 '이미지 관리' 다이얼로그에서 수행하도록 유도.
- 버튼이 2개가 됨에 따라 텍스트 필드 상단 공간이 부족해질 수 있으므로, `MainAxisAlignment.spaceBetween`과 `Row` 레이아웃의 간결함 유지 필요.
