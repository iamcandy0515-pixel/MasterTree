# 🧩 작업 계획서: Quiz Extraction Step2 Screen 리팩토링 및 가속화 (Rev. 2)

이 문서는 `quiz_extraction_step2_screen.dart`의 200라인 초과 이슈를 해결하고, 래퍼 위젯 기반의 모듈화와 성능 최적화를 위한 상세 계획을 담고 있습니다.

## 1. 분석 및 문제 정의 (Analysis)
### 1.1 현상 파악 (Current State)
- **파일 경로**: `lib/features/quiz_management/screens/quiz_extraction_step2_screen.dart`
- **파일 크기**: **425라인** (규칙 1-1. 200줄 제한 위반)
- **주요 병목**:
    - 스티키 헤더 및 필터 정보 로직이 메인 `build` 내부에 직접 구현됨.
    - 추출 상세 모듈(3~7번)을 부모 파일에서 리스트 형태로 직접 제어하고 있어 코드량이 비대함.
    - 다수의 `TextEditingController` 관리가 산재되어 있음.

### 1.2 확정된 전략 (Selected Strategy)
1. **ExtractionDataForm 래퍼 도입**: 3번부터 7번까지의 상세 모듈을 하나의 중간 래퍼 위젯으로 묶어 부모 위젯의 복잡도를 낮춤. (컨트롤러 주입 방식 유지)
2. **Glassmorphism 스티키 헤더**: 불투명도가 조절된 반투명 디자인을 적용하여 세련된 모바일 관리자 UX 제공.
3. **컴포넌트 중심 분리**: 필터 요약, 헤더, 상세 폼 등 논리적 단위로 소스를 쪼개어 파일당 200라인 이하(규칙 1-1) 보장.

---

## 2. 상세 작업 단계 (Execution Phases)

### Phase 1: 사전 준비 및 위젯 추출 (Modularization)
- **1-1. [0-1. Git 백업]** 현재 상태를 로컬 Git에 커밋.
- **1-2. 위젯 소스 분리**: `lib/features/quiz_management/screens/widgets/quiz_extraction/` 디렉토리에 생성.
    - `quiz_extraction_sticky_header.dart`: Glassmorphism 효과가 적용된 뒤로가기 및 제목 영역.
    - `quiz_extraction_filter_summary.dart`: 상단 과목/년도/회차 필터 칩 영역.
    - `quiz_extraction_data_form.dart`: 5개의 상세 모듈(3~7번)을 총괄 관리하는 중간 래퍼 위젯.

### Phase 2: 로직 최적화 및 메인 화면 재구성 (Integration)
- **2-1. 공통 위젯 연동**: `quiz_extraction_step2_screen.dart`에서 추출된 위젯들을 조립.
- **2-2. 컨트롤러 라이프사이클 관리**: `initState`와 `dispose`를 유지하되, `build` 메서드는 위젯 조립 로직 위주로 **120라인 이하**로 축소.
- **2-3. UI 정합성 체크**: `SafeArea` 및 스크롤 패딩 처리 등 모바일 환경 로딩 부하 최적화 (규칙 1-3).

### Phase 3: 최종 검증 및 마무리
- **3-1. [1-3. 분리 후 에러 체크]** 컨트롤러 동기화 및 추출 동작 정상 여부 재확인.
- **3-2. [3-2. 린트 체크]** `flutter analyze` 명령어로 문법 및 스타일 체크.
- **3-3. [0-4. 소스 정합성]** `git diff` 분석을 통한 의도치 않은 코드 누락 방지.
- **3-4. [0-2. Git 최종 커밋]** 리팩토링 완료 상태 커밋.

---

## 3. To-Do List (Checklist)

### 구현 전 (Pre-Implementation)
- [ ] **[0-1. Git 백업]** 현재 상태 커밋 (`git commit -m "pre-refactor: backup quiz_extraction_step2_screen"`)
- [ ] `ExtractionDataForm`에 전달해야 할 10여 개의 컨트롤러 매개변수 명세 확정

### 구현 중 (Implementation)
- [ ] `quiz_extraction_sticky_header.dart` 분리 (Glassmorphism 적용)
- [ ] `quiz_extraction_filter_summary.dart` 분리
- [ ] `quiz_extraction_data_form.dart` 분리 (모듈 3~7 래핑)
- [ ] `quiz_extraction_step2_screen.dart` 메인 파일 슬림화 (200라인 이하 달성)

### 구현 후 (Post-Implementation)
- [ ] **[1-3. 분리 후 에러 체크]** 화면 전환 시 컨트롤러 누출(Leak) 여부 및 UI 정합성 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 수행 및 이슈 해결
- [ ] **[0-4. 소스 정합성]** 최종 소스 diff 확인 및 유실 방지 체크
- [ ] **[0-2. Git 최종 커밋]** 리팩토링 완료 상태 커밋

---

## 4. 기대 효과 (Expected Outcomes)
- **구조적 명확성**: 425라인 -> 100라인 내외로 축소되어 유지보수 포인트가 명확해짐.
- **디자인 세련미**: Glassmorphism 헤더를 통해 모바일 환경에서 더 프리미엄한 관리자 앱 화면 제공.
- **성능 안정성**: 모듈화된 위젯 구조와 검증된 비즈니스 로직 연동을 통해 빌드 정합성 확보.
