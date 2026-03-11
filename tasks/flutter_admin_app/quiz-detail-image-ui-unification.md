# 작업 계획서: 기출문제 상세 화면 이미지 관리 UI 통일 및 개선 (v1)

## 1. 개요

관리자 앱의 '문제 상세내용(QuizReviewDetailScreen)' 화면에서 '문제' 섹션과 '정답 및 해설' 섹션의 이미지 관리 기능을 완전히 동일하게 통일합니다. 특화된 위젯인 `QuizImageEditorSection`을 도입하여 코드 중복을 제거하고, 이미지를 텍스트 영역 하단에 배치하여 가독성을 높입니다.

## 2. 주요 개선 사항

### 2.1 기능 통일 (Unification)

- **아이콘 기능 적용**: '정답 및 해설' 섹션에만 있던 상세 이미지 관리 및 AI 검토(필요시) 관련 UI 구성을 '문제' 섹션에도 동일하게 적용합니다.
- **이미지 추가 및 보기**: 두 섹션 모두 동일한 '이미지 추가'(`Icons.add_photo_alternate`) 및 '이미지 펼치기'(`Icons.photo_library`) 아이콘을 제공합니다.

### 2.2 레이아웃 변경 (Image-Below-Text)

- **위치 조정**: 현재 텍스트 필드 상단에 가로로 작게 표시되던 이미지 미리보기를, 아이콘 클릭 시 **텍스트 필드 하단**에 본문 폭에 맞춘 원본 크기(원본 비율 유지)로 보여주는 방식으로 변경합니다.
- **Ctrl+V 안내**: 입력 필드 포커스 시 나타나는 '이미지 붙여넣기' 지침을 두 섹션 모두 명확하게 표시합니다.

### 2.3 코드 구조 개선

- **공통 위젯 사용**: `quiz_review_detail_screen.dart` 내부의 수동 렌더링 방식(`_buildSectionWithImages`)을 제거하고, `QuizImageEditorSection` 공통 위젯으로 교체합니다.

## 3. 작업 단계

### 1단계: 위젯 통합 및 속성 매핑 (`quiz_review_detail_screen.dart`)

- `_buildSectionWithImages` 호출부를 `QuizImageEditorSection` 위젯 사용으로 변경.
- '문제'(`content_blocks`)와 '해설'(`explanation_blocks`) 각각에 대해 `FocusNode`, `isExpanded` 상태 등을 매핑.

### 2단계: 이미지 노출 위치 및 스타일 조정

- `QuizImageEditorSection` 내부 레이아웃을 확인하여, 이미지가 `TextField` 아래에 배치되도록 보장.
- 확장 상태(`isExpanded`) 시 이미지가 원본 비율을 유지하며 한 화면에 시원하게 보이도록 CSS 및 constraints 조정.

### 3단계: 이벤트 핸들러 연결

- `onPickImage`, `onDeleteImage`, `onPaste`, `onToggleExpand` 등의 콜백을 기존 `QuizReviewDetailScreen`의 메소드들과 정확히 연결.
- '문제' 섹션에서도 필요한 경우 AI 기반 검토 기능을 호출할 수 있도록 준비 (추후 프롬프트 최적화 포함).

### 4단계: 최종 정합성 및 UX 테스트

- 문제 섹션 이미지 추가 -> 이미지 펼치기 -> 텍스트 하단 노출 확인.
- 해설 섹션 이미지 추가 -> Ctrl+V 동작 확인.
- 저장 시 `content_blocks`와 `explanation_blocks`에 이미지가 올바르게 저장되는지 확인.

## 4. 기대 효과

- **UX 일관성**: 어디서든 동일한 방식으로 이미지를 관리할 수 있어 사용자 혼란 방지.
- **편집 편의성**: 이미지를 텍스트와 함께 큰 화면으로 대조하며 편집 가능.
- **유지보수 용이성**: 공통 위젯 사용으로 향후 기능 확장 시 동시 적용 가능.
