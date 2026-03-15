# 🧩 사용자 관리 화면 리팩토링 및 모듈화 계획서 (UserCheck Scopes Refactoring)

이 계획서는 `flutter_admin_app`의 `user_check_screen.dart` 소스를 `DEVELOPMENT_RULES.md` 가이드라인에 따라 200줄 이하로 경량화하고, 각 기능별 책임 분리를 통해 **성능**과 **프리미엄 UI**를 동시에 확보하기 위한 2차 리팩토링 가이드를 정의합니다.

## 0. 작업 전제 조건 (Prerequisites)
- [ ] **Git 백업**: `git add .` 및 `git commit`을 통해 현재 상태 저장.
- [ ] **환경 설정**: `chcp 65001` 터미널 인코딩 확인.

## 1. 리팩토링 및 모듈화 전략 (Modularization Strategy)
현재 315줄인 단일 파일을 논리적 위젯 단위로 분리하여 코드의 복잡도를 낮춥니다. (`Rule 1-1`)

- **분리 경로**: `lib/features/dashboard/screens/widgets/user_check_parts/`
- **추출 대상 위젯**:
    1. `UserSearchHeader.dart`: 탭 컨트롤러 및 검색 입력창 영역.
    2. `UserCardItem.dart`: 사용자 기본 정보(아바타, 이름, 연락처) 및 상태 배지 렌더링.
    3. `UserActionButtons.dart`: 승인/거절/정지 등 상태별 가변 액션 버튼 로직.
    4. `UserDeleteDialog.dart`: 사용자 삭제 확인을 위한 독립된 다이얼로그 모듈.
- **성능 최적화**: `context.watch` 대신 `Selector`를 도입하여 리스트 스크롤 및 검색 시 렌더링 부하 최소화 (`Rule 1-2`).

## 2. 작업 To-Do List

### Phase 1: 파일 구조화 및 위젯 분리
- [x] 신규 폴더 생성 및 위젯 파일 스캐폴딩.
- [x] `UserCardItem` 및 `UserActionButtons` 추출 (복잡한 조건부 렌더링 캡슐화).
- [x] `UserDeleteDialog` 별도 정적 유틸 또는 위젯으로 분리.
- [x] **[Git Commit]**: 물리 위젯 분리 완료.

### Phase 2: 상태 관리 고도화 (Selector 패턴 적용)
- [x] `UserCheckScreen` 메인 위젯에서 `Selector`를 사용하여 리스트 데이터 변화만 감시.
- [x] 검색(onChanged) 시 무거운 위젯 레이어 리빌드 차단.
- [x] **[Git Commit]**: 부분 리빌드 성능 최적화 완료.

### Phase 3: 프리미엄 디자인 고도화 (Visual Excellence)
- [x] `NeoTheme` 스타일을 적극 활용한 카드 배경 및 광택 효과 강화.
- [x] 버튼 클릭 시 `AnimatedScale` 또는 피드백 효과 추가.
- [x] **[Git Commit]**: 디자인 시스템 정밀 적용 완료.

### Phase 4: 완결성 검증 및 빌드
- [x] `flutter analyze`를 통한 린트 에러 제로 확인.
- [x] 관리자 앱 APK 디버그 빌드 (`flutter build apk --debug`).
- [x] **마지막 Git Commit**: "Optimize UserCheckScreen with modular widgets and Selector".

## 3. 정합성 최종 체크리스트
- [x] `user_check_screen.dart` 메인 소스가 150줄 이내로 경량화되었는가?
- [x] 사용자 삭제/승인/거절 시 스낵바 및 결과 피드백이 정상인가?
- [x] `Selector` 도입으로 검색 속도가 눈에 띄게 개선되었는가?

---
**에이전트 준수 사항**: 본 계획서 검수 후 "진행해줘"라고 말씀해 주시면 작업을 시작합니다. 코드 수정 전 반드시 개발자님의 확인을 받겠습니다.
