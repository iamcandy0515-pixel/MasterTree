# 🧩 작업계획서: Hub Screen 기능 분리 및 모듈화

## 1. 개요 (Overview)
- **작업명**: `lib/screens/hub_screen.dart` 소스 분리 및 리팩토링
- **배경**: 현재 `hub_screen.dart`가 약 416라인으로, 운영 규칙인 **[1-1. 200줄 제한 원칙]**을 초과함. 모바일 로드 부하 절감 및 유지보수성 향상을 위해 기능별 위젯 추출이 필요함.
- **담당**: Antigravity (AI Coding Assistant)

## 2. 작업 전제 조건 (Pre-requisites)
- [ ] **[0-1. Git 백업]** 현재 작업 브랜치의 상태를 `git commit` 또는 `git stash`로 백업 확인.
- [ ] **[0-2. 환경 설정]** 터미널 인코딩 `chcp 65001` 적용 확인.
- [ ] **[4-1. 버전 준수]** Flutter `3.7.12`, Dart `2.19.6` 환경 유지 및 검증.

## 3. 리팩토링 전략 (Refactoring Strategy)
- **디렉토리 구조**: `lib/screens/hub/widgets/` 경로를 생성하여 물리적 소스 분리.
- **위젯 추출 대상**:
    1. `HubHeader`: 상단 로고, 타이틀, 알림/로그아웃 버튼.
    2. `HubMenuCard`: 유리 필터 효과가 적용된 개별 메뉴 버튼.
    3. `HubGuideSection`: 학습 가이드 팁 섹션.
    4. `HubBottomNav`: 하단 내비게이션 바 및 아이템.
- **데이터 통신**: **[1-2. 효율적 통신 및 콜백]**에 따라 부모(`HubScreen`)와 자식 위젯 간의 이벤트 전달은 명확한 Callback 인터페이스를 정의하여 처리.

## 4. To-Do List
### Phase 1: 위젯 소스 분리
- [x] `lib/screens/hub/widgets/hub_header.dart` 생성 및 추출
- [x] `lib/screens/hub/widgets/hub_menu_card.dart` 생성 및 추출
- [x] `lib/screens/hub/widgets/hub_guide_section.dart` 생성 및 추출
- [x] `lib/screens/hub/widgets/hub_bottom_nav.dart` 생성 및 추출

### Phase 2: 메인 스크린 재구성
- [x] `lib/screens/hub_screen.dart` 내 중복 코드 제거 및 신규 위젯 Import
- [x] `HubScreen`의 UI 구조 정합성 체크 (Overflow 방지)
- [x] 로그아웃 및 네비게이션 콜백 함수 연결

### Phase 3: 검증 및 최적화
- [ ] **[1-3. 분리 후 에러 체크]** Import 경로 및 UI 렌더링 정상 여부 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 명령어로 린트 에러 제로(0) 확인
- [x] **[0-4. 소스 정합성]** `diff` 분석을 통해 의도치 않은 코드 삭제 여부 최종 확인

## 5. 기대 효과 (Expected Outcomes)
- `hub_screen.dart` 파일 크기 70% 이상 축소 (100라인 이내).
- 위젯화된 컴포넌트의 `const` 최적화를 통한 런타임 성능 개선.
- 향후 기능 확장 시(예: 새로운 메뉴 추가) 코드 수정 범위 최소화.

---
**주의**: 본 계획서는 개발자의 최종 승인 후 구현을 시작합니다.
