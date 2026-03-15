# 🧩 SmartTagImageSection 고도화 및 성능 최적화 계획서 (Refining & Optimization)

이 계획서는 `SmartTagImageSection.dart`를 논리적/물리적으로 더 세분화하여 **가독성**을 극대화하고, 모바일 환경에서의 **렌더링 부하를 최소화**하기 위한 2차 리팩토링 가이드를 정의합니다.

## 0. 작업 전제 조건 (Prerequisites)
- [x] **Git 백업**: `git add .` 및 `git commit`을 통해 현재 상태 저장.
- [x] **환경 설정**: `chcp 65001` 인코딩 확인.

## 1. 리팩토링 전략 (Refactoring Strategy)

### 1-1. 위젯 물리 분리
- **ActiveTagEditor 추출**: 현재 `SmartTagImageSection` 내부에 있는 비대한 `_buildActiveTagEditor` 함수를 별도 위젯 파일로 분리합니다.
- **경로**: `lib/features/tree_registration/screens/widgets/tree_registration_parts/active_tag_editor.dart`

### 1-2. 부분 리빌드 최적화 (Selective Rebuild)
- 섹션 전체에 `context.watch`를 사용하는 대신, `Selector` 패턴을 도입하여 **이미지 데이터가 실제로 바뀔 때만** 하위 위젯이 그려지도록 최적화합니다. 이는 모바일 기기에서의 CPU 사용량을 줄이는 핵심 작업입니다.

### 1-3. 렌더링 레이어 분리 (Repaint Boundary)
- 이미지 영역에 `RepaintBoundary`를 적용하여, 텍스트 입력(힌트) 시 무거운 이미지 픽셀이 매 프레임 다시 계산되는 것을 방지합니다.

## 2. 작업 To-Do List

### Phase 1: 위젯 추출 및 구조화
- [x] `ActiveTagEditor` 클래스 생성 및 `SmartTagImageSection`에서 로직 이관.
- [x] 부모 위젯에서 자식 위젯으로 필요한 콜백 및 데이터 전달 구조 정립.
- [x] **[Git Commit]**: 물리 분리 완료.

### Phase 2: 성능 고도화 (State Management Optimization)
- [x] `SmartTagImageSection` 내부에 `Selector` 위젯 적용.
- [x] `TreeRegistrationViewModel`에서 필요한 최소 데이터(activeTag, image)만 감시하도록 수정.
- [x] **[Git Commit]**: Selector 패턴 적용 완료.

### Phase 3: 모바일 렌더링 부하 분산
- [x] 이미지 업로드 영역 및 미리보기 영역에 `RepaintBoundary` 적용.
- [x] `TagHintInput`의 `TextEditingController` 격리 상태 재검증.
- [x] **[Git Commit]**: 렌더링 최적화 완료.

### Phase 4: 최종 검증 및 빌드
- [x] `flutter analyze` 실행 및 린트 에러 제로 확인.
- [x] `flutter build apk --debug` 수행하여 런타임 안정성 체크.
- [x] **마지막 Git Commit**: "Optimize SmartTagImageSection with Selector and RepaintBoundary".

## 3. 정합성 최종 체크리스트
- [x] `SmartTagImageSection.dart`가 60줄 이하로 경량화되었는가?
- [x] 다른 필드 입력 시 이미지 위젯의 불필요한 리빌드가 차단되었는가?
- [x] `RepaintBoundary`가 적절한 위치에 배치되었는가?

---
**에이전트 준수 사항**: 본 계획서 검토 후 "진행해줘"라고 말씀하시면 작업을 시작하며, 코드를 수정하기 전 항상 개발자님께 확인을 받습니다.
