# 🧩 수목 등록 화면 리팩토링 및 모바일 최적화 작업 계획서 (Tree Registration Modularization)

이 계획서는 `DEVELOPMENT_RULES.md`를 엄격히 준수하여 `tree_registration_screen.dart` 및 관련 위젯을 리팩토링하고 모바일 환경에 최적화하기 위한 단계별 가이드를 정의합니다.

## 0. 작업 전제 조건 (Prerequisites)
- [x] **Git 백업**: `git add .` 및 `git commit`을 통해 현재 소스 상태 백업.
- [x] **환경 설정**: 터미널 실행 전 `chcp 65001` 명령으로 한글 인코딩 보장.
- [x] **소스 정합성**: 작업 전후 `diff` 분석을 통해 의도하지 않은 코드 삭제 방지.

## 1. 코드 구조 및 모듈화 전략 (Source Splitting)
`Rule 1-1`에 의거하여 200줄이 넘는 `SmartTagImageSection.dart` (현재 259줄)를 물리적으로 분리합니다.

- **대상 파일**: `lib/features/tree_registration/screens/widgets/smart_tag_image_section.dart`
- **분리 목표 위젯**:
    - `TagSelectorRow.dart`: 부위별 선택 칩(Chips) UI (약 60~80줄 예상).
    - `TagImageDisplay.dart`: 이미지 미리보기 및 삭제 버튼 영역 (약 50~70줄 예상).
    - `TagUploadActions.dart`: 업로드/복사/검색 버튼 그룹 (약 80~100줄 예상).
    - `TagHintInput.dart`: 힌트 입력 텍스트 필드 영역 (약 40~60줄 예상).
- **통신 방식**: 부모-자식 간 `Callback` 패턴을 사용하여 `TreeRegistrationViewModel`과의 정합성 유지 (`Rule 1-2`).

## 2. 작업 To-Do List (Task Workflow)

### Phase 1: 위젯 물리 분리 및 경로 정리
- [x] 신규 폴더 생성: `lib/features/tree_registration/screens/widgets/tree_registration_parts/`
- [x] 200줄 초과 방지를 위한 4개 위젯 클래스 추출 및 개별 파일 생성.
- [x] Import 경로 에러 및 린트(Lint) 에러 사전 체크 (`Rule 1-3`, `3-2`).
- [x] **[Git Commit]**: 위젯 분리 완료 및 기본 연동 확인.

### Phase 2: 모바일 최적화 및 인프라 구현
- [x] **이미지 압축 (Optimization)**: `ImageProcessingUtil`을 연동하여 업로드 전 바이트 최적화.
- [x] **WebUtils 적용 (Rule 4-3)**: `dart:html` 직접 참조 제거 및 `WebUtils` 추상화 레이어를 통한 클립보드 처리.
- [x] **성능 튜닝**: `TextEditingController`를 자식 위젯 내부에서 관리하여 모바일 리빌드 부하 분산.
- [x] **[Git Commit]**: 성능 및 인프라 로직 적용 완료.

### Phase 3: 디자인 고도화 (Premium Aesthetics)
- [x] **UI 시인성 강화**: 각 섹션 컨테이너에 `boxShadow` (그림자) 및 `border` (외곽선) 적용.
- [x] **상태 피드백**: API 호출 상태(정상/비정상/지연)를 텍스트로 표시하는 인디케이터 상단 배치.
- [x] **[Git Commit]**: 디자인 고도화 완료.

### Phase 4: 컴파일 및 빌드 완결성 확인 (Rule 2-3, 4-1)
- [x] 빌드 버전 고정 확인: Gradle 8.5, Kotlin 1.9.22 유지 검증.
- [x] AndroidX Resolution Strategy가 빌드에 정상 반영되는지 체크 (`Rule 4-4`).
- [x] **최종 분석**: `flutter analyze` 실행하여 모든 이슈 해결.
- [x] **최종 빌드**: `flutter build apk --debug` 수행하여 실행 파일 생성 확인.
- [x] **마지막 Git Commit**: "Complete TreeRegistration modularization and mobile optimization".

## 3. 정합성 최종 체크리스트
- [x] 모든 파일이 200줄 이하인가?
- [x] `WebUtils`를 사용하여 플랫폼 호환성을 확보했는가?
- [x] `chcp 65001` 환경에서 작업이 수행되었는가?
- [x] `flutter analyze` 결과 'Critical' 이슈가 없는가?

---
**에이전트 준수 사항**: 본 계획서 승인 후에만 구현을 시작하며, 모든 코드 수정 후 반드시 린터를 가동한다.
