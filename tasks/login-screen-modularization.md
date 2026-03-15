# LoginScreen 리팩토링 및 모듈화 작업 계획서

이 계획서는 `DEVELOPMENT_RULES.md` 표준을 준수하며, `flutter_user_app`의 로그인 화면을 경량화하고 성능을 최적화하는 것을 목표로 합니다.

## 1. 개요
- **대상**: `lib/screens/login_screen.dart` (현재 431라인)
- **목표**: 
  - 단일 파일 200라인 제한 준수 (`Rule 1-1`)
  - MVVM 패턴 도입으로 비즈니스 로직과 UI 분리
  - `Selector`를 통한 성능 최적화
  - 빌드 및 린트 완결성 확보 (`Rule 2-3, 3-2`)

---

## 2. 작업 To-Do List

### [Phase 0] 작업 준비 및 백업 (Rule 0-1)
- [ ] 현재 작업 소스 로컬 Git 커밋 (`git commit -m "Pre-refactor: login_screen backup"`)

### [Phase 1] 로직 분리 및 ViewModel 구축 (MVVM)
- [ ] `lib/utils/auth_data_formatter.dart` 생성 및 연락처 포맷터 이동
- [ ] `lib/viewmodels/auth_viewmodel.dart` 생성 (AuthController 기능 이관)
- [ ] 유효성 검사(Validation) 로직을 ViewModel로 이동
- [ ] 로컬 Git 커밋 (`Phase 1: ViewModel migration complete`)

### [Phase 2] 위젯 추출 (Source Splitting - Rule 1-1)
`lib/screens/widgets/login_parts/` 폴더 내에 200라인 이하로 위젯 분리:
- [ ] `login_header.dart`: 로고 및 상단 타이틀
- [ ] `login_input_fields.dart`: 이름, 휴대폰, 이메일 입력 필드 (`Selector` 사용)
- [ ] `login_action_buttons.dart`: 입장하기, 데이터 삭제 버튼
- [ ] `login_status_overlay.dart`: 로딩 및 서버 상태 안내 레이어
- [ ] 로컬 Git 커밋 (`Phase 2: Widget modularization complete`)

### [Phase 3] 화면 재조립 및 최적화
- [ ] `login_screen.dart`를 Composition Root로 재작성 (100라인 이내)
- [ ] `Provider` 및 `ChangeNotifierProvider` 연결
- [ ] 린트 에러 및 Import 경로 정합성 체크 (Rule 1-3)
- [ ] 로컬 Git 커밋 (`Phase 3: Screen re-composition complete`)

### [Phase 4] 품질 검증 및 최종 점검 (Rule 2-3, 3-2)
- [ ] `flutter analyze` 실행 및 모든 경고 해결
- [ ] 한글 깨짐 방지(`chcp 65001`) 상태에서 빌드 완결성 확인
- [ ] 최종 Git 커밋 및 작업 종료

---

## 3. 리스크 및 예방 조치
- **UI Overflow**: 분리된 위젯 조립 시 `SingleChildScrollView` 및 `Flexible` 구조 유지 여부 확인.
- **Import Error**: 모듈화로 인한 경로 복잡화 방지를 위해 상대 경로 정밀 체크.
- **성능**: 텍스트 입력 시 전체 화면이 리빌드되지 않도록 `Selector`와 `read()`를 적절히 배분.

---

**주의**: 개발자님의 최종 승인 후 구현을 시작합니다. 위 계획서대로 진행해도 될까요?
