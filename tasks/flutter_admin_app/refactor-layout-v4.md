# Task: 수목 상세 레이아웃 시인성 개선 및 Overflow 방지 (V4)

## 상태 기록 (Plan)

- **목적**: 입력 필드 경계 명확화 및 미려한 Glassmorphic 디자인 적용으로 UI 완성도 향상
- **주요 수정 사항**:
    1. **입력 필드 스타일 현대화**:
        - `_buildTextField` 디자인에 `NeoColors.acidLime` 포인트 하단 라인 및 포커스 효과 적용.
        - `_inputDecoration`을 수정하여 입력창의 깊이(Depth) 표현.
    2. **기본 정보 섹션 (Inline Layout)**:
        - `수목명: [필드]` 형태의 인라인 레이아웃을 위해 `_buildInlineField` 신설.
        - 긴 텍스트 입력 시 레이아웃 침범을 막기 위해 `Flexible`/`Expanded` 구조 최적화.
    3. **퀴즈 오답(Distractors) 고도화**:
        - 각 오답 항목을 구분하는 미세한 구분선 추가.
        - 번호 색상을 강조하여 리스트 가독성 향상.
    4. **이미지 힌트 그리드 최적화**:
        - 화면 너비에 따라 `childAspectRatio`가 유동적으로 변하지 않도록 고정값 점검 및 `BoxConstraints` 활용.

- **대상 파일**: `lib/features/trees/screens/tree_detail_screen.dart`

## 실행 (Execute)

1. **`_buildTextField` 및 `_inputDecoration` 리팩토링**
    - [ ] `filled: true`, `fillColor: Colors.white.withOpacity(0.03)` 적용
    - [ ] `enabledBorder/focusedBorder`에 `UnderlineInputBorder` 적용
2. **`_buildInlineField` 도입 및 기본 정보 섹션 적용**
    - [ ] 수목명, 학명, 구분 필드에 인라인 스타일 적용
    - [ ] `Row` 내부의 `SizedBox` 간격 및 `Flexible` 가중치 조정
3. **퀴즈 오답 리스트 구분선 추가**
    - [ ] `_buildDistractorList`의 각 `Row` 하단에 `Border` 또는 `Divider` 효과 추가
4. **전체 스크롤 뷰 및 Overflow 점검**
    - [ ] 하단 버튼 영역과의 `Padding` 최적화

## 사후 점검 (Review)

- **완료된 결과 (Result)**:
    - **인라인 필드 최적화**: 수목명, 학명, 구분 필드에 `_buildInlineField`를 적용하여 가로 공간 효율성을 극대화함.
    - **시인성 개선**: `UnderlineInputBorder`와 미세한 배경색(`Colors.white.withOpacity(0.03)`)을 조합하여 입력 가능 영역을 명확히 구분함.
    - **안정성 강화**: `Expanded(flex: n)` 구조를 통해 다양한 화면 너비에서 텍스트 오버플로우 없이 유연하게 대응함.
    - **리스트 디테일**: 퀴즈 오답 항목에 구분선 및 강조 번호를 추가하여 가독성을 개선함.

- **향후 문제점 및 리스크 분석 (Risk Analysis)**:
    - **매우 좁은 모바일 화면**: 가로 모드에서는 안정적이나, 세로 모드가 매우 좁은 기기(예: iPhone SE)에서는 `Row` 내의 텍스트가 겹칠 가능성이 여전히 존재함. (필요 시 `Wrap`으로 전환하는 로직 추가 검토 필요)
    - **저사양 기기 렌더링**: 반투명 배경색(`withOpacity`) 연산이 많아질 경우 하드웨어 가속이 없는 저사양 기기에서 미세한 프레임 드랍이 있을 수 있음 (현재 수준은 권장 범위 내).
