# 🧩 작업계획서: 사용자 통계 화면(UserStatsScreen) 고도화 및 위젯 분리

## 1. 개요 (Overview)
- **작업명**: `lib/screens/user_stats_screen.dart` 소스 코드 분리 및 모바일 로딩 최적화
- **배경**: 현재 `user_stats_screen.dart`는 327라인으로 **[1-1. 200줄 제한 원칙]**을 초과하며, 3개 탭의 모든 위젯 빌더가 한 파일에 있어 모바일 기기에서의 렌더링 부하 및 코드 복잡도가 높음.
- **담당**: Antigravity (AI Coding Assistant)

## 2. 작업 전제 조건 (Pre-requisites)
- [ ] **[0-1. Git 백업]** 구현 시작 전 현재 소스 코드의 `git commit` 확인.
- [ ] **[0-2. 환경 설정]** 터미널 인코딩 `chcp 65001` 적용 확인.
- [ ] **[4-1. 버전 준수]** Flutter `3.7.12`, Dart `2.19.6` 환경 유지.

## 3. 모바일 최적화 및 리팩토링 전략 (Optimization Strategy)
- **모바일 로드 부하 절감**: 탭 전환 시 필요한 위젯만 생성하도록 분리하고, 모든 정적 위젯에 `const` 생성자를 적용하여 불필요한 Repaint 방지. **[3-1. 성능 최적화]**
- **컴포넌트 독립화**: 반복되는 통계 카드 디자인을 `lib/screens/user_stats/widgets/stat_summary_card.dart`로 독립하여 코드 중복 70% 제거.
- **탭별 위젯화**: `Overall`, `Quiz`, `PastExam` 탭을 각각 독립 파일로 분산하여 단일 파일 크기를 150라인 미만으로 유지.
- **효율적 통신**: **[1-2. 효율적 통신]** 원칙에 따라 콜백 함수를 활용하여 데이터 새로고침 로직 연동.

## 4. To-Do List
### Phase 1: 공통 컴포넌트 및 하위 위젯 추출
- [x] `lib/screens/user_stats/widgets/stat_summary_card.dart` 구현 (공통 카드 UI 컴포넌트)
- [x] `lib/screens/user_stats/tabs/overall_stats_tab.dart` 추출 (종합 통계 요약 탭)
- [x] `lib/screens/user_stats/tabs/quiz_stats_tab.dart` 추출 (퀴즈 학습 성과 탭)
- [x] `lib/screens/user_stats/tabs/past_exam_stats_tab.dart` 추출 (기출 문제 학습 성과 탭)

### Phase 2: 메인 화면 재구성 및 연동
- [x] `UserStatsScreen` 내 기존 위젯 빌더 메서드(`_buildOverallTab` 등) 제거
- [x] 메인 화면에서 신규 추출한 탭 위젯으로 `TabBarView` 구성
- [x] 새로고침(Refresh) 로직의 안정적인 데이터 바인딩 확인

### Phase 3: 검증 및 최종 점검
- [x] **[1-3. 에러 체크]** 데이터 로딩 실패 시 에러 뷰(ErrorView) 및 다시 시도 기능 검증
- [x] **[3-2. 린트 체크]** `flutter analyze` 명령어로 스타일 및 문법 오류 제로(0) 확인 (기존 이슈 제외)
- [x] **[0-4. 소스 정합성]** `git diff` 분석을 통해 의도치 않은 로직 삭제 여부 최종 확인

## 5. 기대 효과 (Expected Outcomes)
- `UserStatsScreen` 파일이 대폭 축소되어 핵심 구조(AppBar, TabBar) 파악이 용이해짐.
- 위젯 분리를 통해 모바일 환경에서 탭 전환 시 더 부드러운 애니메이션 및 렌더링 성능 확보.
- 코드 모듈화로 인해 향후 새로운 통계 탭(예: 오답 노트 통계) 추가 시 확장성 극대화.

---
**주의**: 본 계획서는 개발자의 최종 승인 후 구현을 시작합니다.
