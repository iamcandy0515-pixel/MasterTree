# 🧩 작업 계획서: Bulk Quiz Extraction Screen 리팩토링 및 모듈화 (Rev. 2)

이 문서는 `bulk_extraction_screen.dart`의 200라인 초과 이슈를 해결하고, `DEVELOPMENT_RULES.md`를 준수하며 대량 추출 프로세스의 사용성 및 안정성을 높이기 위한 상세 계획입니다.

## 1. 분석 및 문제 정의 (Analysis)
### 1.1 현상 파악 (Current State)
- **파일 경로**: `lib/features/quiz_management/screens/bulk_extraction_screen.dart`
- **파일 크기**: **421라인** (규칙 1-1. 200줄 제한 위반)
- **주요 병목**:
    - 중앙 집중형 오버레이 및 다이얼로그 노출 코드가 메인 소스의 비중을 크게 차지함.
    - 대량 추출 시 상태 업데이트(`current/total`) 알림 방식이 파편화되어 있음.
    - 추출 중단(Cancel) 기능 부재로 인해 대량 작업 시 제어권이 없음.

### 1.2 확정된 전략 (Selected Strategy)
1. **데이터 저장 최적화**: 탭 전환 시점에 저장 로직을 트리거하고, 주기적인 자동 저장(Autosave)을 ViewModel에 구현하여 데이터 안전성을 확보함.
2. **비침습적 알림 시스템**: 중앙 팝업을 가급적 지양하고, 상단 **스낵바(Snackbar)**와 **진행률 프로그레스바**를 결합하여 실시간 추출 상태를 표시함.
3. **추출 중단(Cancel) 기능 도입**: 대량 추출 중 사용자가 언제든 멈출 수 있는 중단 플래그(`_isCancelled`) 로직을 구현하여 불필요한 API 호출 및 비용 발생을 차단함.

---

## 2. 상세 작업 단계 (Execution Phases)

### Phase 1: 위젯 및 로직 분리 (Modularization)
- **1-1. [0-1. Git 백업]** 작업 전 현재 상태를 로컬 Git에 커밋.
- **1-2. 공통 UI 추출**: `lib/features/quiz_management/screens/widgets/bulk_extraction/` 활용.
    - `bulk_extraction_header.dart`: 앱바 및 DB 등록 액션.
    - `bulk_extraction_progress_bar.dart`: 상단 진행률 프로그레스바 전용 위젯.
    - `bulk_extraction_status_overlay.dart`: 로딩 중 및 성공 알림 오버레이(스낵바 연동).
    - `bulk_extraction_dialog_helper.dart`: 저장 확인 등 다이얼로그 UI 모음.

### Phase 2: 비즈니스 로직 고도화 및 화면 재구성
- **2-1. ViewModel 업데이트**:
    - `cancelExtraction()` 메서드 및 `_isCancelled` 플래그 추가.
    - 탭 전환 시 자동 데이터 맵 갱신 및 주기적 로컬 백업 로직 추가.
- **2-2. Selector 기반 성능 개선**: 진행률 업데이트 시 전체 UI 리빌드 대신 프로그레스바 및 상태 텍스트만 갱신되도록 `Selector` 적용.
- **2-3. 메인 화면 슬림화**: `bulk_extraction_screen.dart`를 핵심 조립 로직만 남기고 **130라인 이하**로 축소.

### Phase 3: 최종 검증 및 마무리
- **3-1. [1-3. 분리 후 에러 체크]** 대량 데이터(50문항 이상) 중단 기능 및 데이터 보존성 확인.
- **3-2. [3-2. 린트 체크]** `flutter analyze` 명령어로 품질 검증.
- **3-3. [0-4. 소스 정합성]** `git diff` 최종 분석.
- **3-4. [0-2. Git 최종 커밋]** 완료 상태 커밋.

---

## 3. To-Do List (Checklist)

### 구현 전 (Pre-Implementation)
- [ ] **[0-1. Git 백업]** 현재 상태 커밋 (`git commit -m "pre-refactor: backup bulk_extraction_screen"`)
- [ ] ViewModel의 `startBatchExtraction` 내부에 중단 플래그 체크 로직 설계

### 구현 중 (Implementation)
- [ ] `bulk_extraction_header.dart` 분리
- [ ] `bulk_extraction_progress_bar.dart` 신규 제작
- [ ] `bulk_extraction_status_overlay.dart` 분리 (스낵바 연동)
- [ ] `bulk_extraction_dialog_helper.dart` 분리
- [ ] ViewModel 중단(Cancel) 및 자동 저장(Autosave) 로직 추가
- [ ] `Selector` 적용을 통한 빌드 성능 최적화
- [ ] `bulk_extraction_screen.dart` 메인 파일 슬림화 (200라인 이하 달성)

### 구현 후 (Post-Implementation)
- [ ] **[1-3. 분리 후 에러 체크]** 추출 중단 시 이전 데이터 정합성 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 수행 및 이슈 해결
- [ ] **[0-4. 소스 정합성]** 최종 소스 diff 확인 및 유실 방지 체크
- [ ] **[0-2. Git 최종 커밋]** 리팩토링 완료 상태 커밋

---

## 4. 기대 효과 (Expected Outcomes)
- **통제권 강화**: 사용자가 언제든 추출을 멈출 수 있어 대량 작업 시 심리적/비용적 리스크 감소.
- **UX 세련미**: 상단 프로그레스바와 스낵바를 통해 작업 흐름을 방해하지 않는 정교한 피드백 제공.
- **성능 및 유지보수성**: 421라인 -> 130라인 축소로 규칙 1-1을 준수하며 향후 기능 확장이 매우 용이함.
