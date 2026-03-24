# 🧩 위젯 리팩토링 및 기술 명세 준수 계획서: DashboardModuleGrid

본 계획서는 `DEVELOPMENT_RULES.md` 및 `FLUTTER_3_7_12_TECH_SPEC.md`의 모든 기술 사양과 작업 규칙을 통합하여 작성되었습니다.

## 1. 개요 및 목적
- **작업 대상**: `flutter_user_app/lib/screens/dashboard/widgets/dashboard_module_grid.dart`
- **현 상태**: 208라인 (200줄 초과), 4개의 메뉴 카드 하드코딩 중복 코드.
- **최종 목표**: `parts` 추출을 통한 100라인 이하 감축, `Flutter 3.7.12 / Dart 2.19.6` 환경에서의 완벽한 호환성 및 모바일 로드 부하 최적화.

## 2. 기술 명세 준수 현황 (Rule & Tech Spec)
- **SDK**: Flutter `3.7.12`, Dart `2.19.6` 고정 준수.
- **Java**: `OpenJDK 17` 환경 확인 (Build Error 사전 예방).
- **Design Structure**: `flutter_user_app/core/design_system.dart` 의 테마 및 컬러 토큰(`AppColors`, `AppRadius`) 철저 활용.
- **Encoding**: 터미널 작업 시 `chcp 65001`을 통한 UTF-8 환경 유지.

## 3. 상세 To-Do List

### 🟢 1단계: 사전 보안 및 백업 (Rule 0-1, 0-2)
- [ ] 현재 상태 로컬 Git 커밋 (`feat: pre-refactor backup for DashboardModuleGrid`)
- [ ] 터미널 인코딩 설정 확인 (`chcp 65001`)

### 🟡 2단계: 위젯 분리 및 중복 제거 (Rule 1-1, 1-3)
- [ ] `flutter_user_app/lib/screens/dashboard/widgets/parts/` 서브 디렉토리 구조 생성.
- [ ] **module_menu_card.dart** 추출: `_buildMenuCard`를 독립적인 `StatelessWidget`으로 추출하여 코드 유연성 확보.
- [ ] **module_guide_section.dart** 추출: 하단 가이드 영역을 독립 위젯화하여 메인 파일 슬림화.
- [ ] **[중복 제거]**: 메인 위젯에서 하드코딩된 4개 메뉴 나열을 데이터 기반의 리스트 맵핑 방식으로 리팩토링.

### 🟠 3단계: 메인 위젯 정리 및 성능 최적화 (Rule 3-1, 4-4)
- [ ] **[Clean Code]**: 메인 위젯 소스량을 100라인 수준으로 축소. `[Rule 3-1]`
- [ ] **[const 최적화]**: 모든 정적 위젯 및 스타일 토큰에 `const`를 적용하여 렌더링 성능 가속.
- [ ] **[웹 격리]**: `[Rule 4-4]`에 따라 모바일 사용자 앱 환경에서의 안정적 배포 전략 점검.

### 🔴 4단계: 최종 검증 (Rule 2-3, 3-2)
- [ ] **[빌드]** `flutter build web` 또는 APK 빌드를 통해 컴파일 오류 확인.
- [ ] **[린트]** `flutter analyze` 실행하여 모든 경고 및 `prefer_final_fields` 이슈 해결.
- [ ] **[정합성]** 대시보드 화면에서 각 학습 모듈(수목도감, 퀴즈, 기출 등) 클릭 시 기존과 동일하게 화면 전환이 발생하는지 테스트.

---
**최종 승인 요청**: 위 기술 명세 및 규칙을 모두 준수하여 리팩토링을 진행하고자 합니다. 승인해 주시면 작업을 시작하겠습니다.
