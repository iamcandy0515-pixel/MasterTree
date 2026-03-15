# 🧩 기출 상세 화면 리팩토링 및 모듈화 계획서 (PastExamDetail Scopes Modularization)

이 계획서는 `flutter_user_app`의 `past_exam_detail_screen.dart` 소스를 `DEVELOPMENT_RULES.md`에 따라 200줄 이하로 경량화하고, 위젯별 책임 분리를 통해 유지보수성과 성능을 최적화하기 위한 가이드를 정의합니다.

## 0. 작업 전제 조건 (Prerequisites)
- [ ] **Git 백업**: `git add .` 및 `git commit`을 통해 현재 상태 저장.
- [ ] **환경 설정**: `chcp 65001` 터미널 인코딩 확인.

## 1. 코드 구조 및 모듈화 전략 (Source Splitting)
현재 471줄인 비대한 파일을 가동성과 성능을 고려하여 5개 이상의 모듈로 분리합니다. (`Rule 1-1`)

- **신규 경로**: `lib/screens/past_exam/` 폴더 내부에 분리 위젯 배치.
- **분리 목표 위젯**:
    1. `ExamInfoBanner.dart`: 년도/회차/과목 정보 표시 영역.
    2. `QuizContentCard.dart`: 문제 텍스트 및 확장형 이미지 렌더링 영역.
    3. `OptionSelectorList.dart`: 5지선다 선택 및 정답/오답 결과 피드백 영역.
    4. `ExplanationPanel.dart`: 해설 이미지 및 텍스트 렌더링 영역.
    5. `RelatedQuizSection.dart`: 유사 문제 리스트 및 링크 영역.
- **통신 전략**: 부모-자식 간 `Callback` 패턴 또는 `Selector`를 활용하여 부분 리빌드 최적화 수행 (`Rule 1-2`).

## 2. 작업 To-Do List

### Phase 1: 위젯 물리 분리 및 구조 설계
- [ ] 신규 폴더 생성: `lib/screens/past_exam/widgets/`
- [ ] 핵심 기능별 클래스 추출 및 파일 분할 (5개 파일).
- [ ] Import 경로 정립 및 린트(Lint) 에러 사전 해결.
- [ ] **[Git Commit]**: 위젯 물리 분리 완료.

### Phase 2: 성능 최적화 (Partial Rebuild)
- [ ] `setState` 의존도 감소를 위해 `Selector` 위젯 도입 검토.
*   [ ] 이미지 영역에 `RepaintBoundary` 적용하여 스크롤 및 텍스트 렌더링 성능 확보.
- [ ] **[Git Commit]**: 리빌드 최적화 로직 적용.

### Phase 3: 디자인 정교화 (Premium Aesthetics)
- [ ] `AppColors`와 `design_system.dart`를 활용한 테마 정합성 유지.
- [ ] 섹션별 `Container`에 `boxShadow` 및 `border` 적용하여 프리미엄 레이아웃 구현.
- [ ] **[Git Commit]**: UI/UX 고도화 완료.

### Phase 4: 완결성 확인 및 빌드 (Rule 2-3)
- [ ] `flutter analyze` 실행하여 모든 경고 및 오류 해결.
- [ ] 사용자 앱 APK 빌드 테스트 (`flutter build apk --debug`).
- [ ] **마지막 Git Commit**: "Complete PastExamDetail refactoring and modularization".

## 3. 정합성 최종 체크리스트
- [ ] `past_exam_detail_screen.dart` 메인 파일이 200줄 이하인가?
- [ ] 모든 하위 위젯이 독립적으로 테스트 가능한 구조인가?
- [ ] `ApiService.syncPendingAttempts()` 등 주요 로직이 유실되지 않았는가?

---
**에이전트 준수 사항**: 본 계획서 승인 후에만 구현을 시작하며, 모든 코드 수정 후 반드시 린터를 가동한다.
