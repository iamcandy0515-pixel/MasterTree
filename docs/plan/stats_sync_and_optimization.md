# 🧩 [작업 계획서] 관리자 앱 상세학습통계 UI/Logic 동기화

관리자 앱의 '상세학습통계(UserDetailStatsScreen)'를 사용자 앱의 '나의 학습통계'와 동일한 3단 탭 구성 및 상세 집계 로직으로 마이그레이션하여, 관리자가 사용자의 학습 현황을 사용자 뷰와 동일하게 모니터링할 수 있도록 고도화합니다.

---

## 📅 작업 정보
- **상태**: 승인 대기 중 (Pending Approval)
- **대상 프로젝트**: lutter_admin_app, 
odejs_admin_api (검증용)
- **표준 환경**: Flutter 3.7.12 / Dart 2.19.6

---

## 🛠️ 핵심 작업 규칙 (DEVELOPMENT_RULES.md 반영)
1. **[1-1. 200줄 제한]**: 단일 파일 소스가 200줄을 넘지 않도록, 각 통계 탭(Overall, Quiz, PastExam)을 별도의 위젯 파일로 분리하여 구현한다.
2. **[4-4. 웹 격리]**: dart:html 등 웹 전용 라이브러리를 직접 사용하지 않고, 기존 프레임워크를 유지하여 모바일 빌드와의 호환성을 보장한다.
3. **[2-3. 빌드 완결성]**: 수정 후 lutter analyze를 실행하여 린트 에러 0건을 유지한다.

---

## 🚀 To-Do List

### 1단계: 데이터 레이어 확장 (Admin API 연동)
- [ ] lib/features/dashboard/repositories/stats_repository.dart 수정
    - getTreeCategoryStats(String userId) 메서드 추가 (GET /stats/categories/:userId)
    - getExamSessionStats(String userId) 메서드 추가 (GET /stats/exams/:userId)
- [ ] lib/features/dashboard/viewmodels/user_detail_viewmodel.dart 수정
    - Map<String, dynamic>? _categoryStats, _examStats 필드 추가
    - loadStats() 내부에 Future.wait를 적용하여 3개 데이터를 동시 병렬 로드하도록 최적화

### 2단계: 소스 분리 및 신규 탭 위젯 구현 (Source Splitting)
- [ ] lib/features/dashboard/widgets/user_detail/ 디렉토리 신설
- [ ] 사용자 앱의 통계 UI 요소를 기반으로 위젯 제작 (분리 원칙 준수):
    - [ ] dmin_overall_stats_tab.dart: 종합 학습 달성률 표시 (200줄 이내)
    - [ ] dmin_quiz_stats_tab.dart: 카테고리별 수목 퀴즈 통계 표시
    - [ ] dmin_past_exam_stats_tab.dart: 기출문제 과목/연도/회차별 필터링 기능 이식
- [ ] 공용 통계 카드 위젯(StatSummaryCard) 마이그레이션

### 3단계: 화면 통합 및 테마 커스텀
- [ ] lib/features/dashboard/screens/user_detail_stats_screen.dart 개편
    - DefaultTabController 구조 유지 및 세부 탭 배치
    - 관리자 앱 전용 테마(primaryColor, ackgroundDark) 적용
    - 상단 '사용자 명' 표시 및 새로고침 로직 리팩토링

### 4단계: 안정성 및 품질 검토
- [ ] UI Overflow 방지를 위한 레이아웃 체크
- [ ] lutter analyze 실행 및 린트 에러 제거
- [ ] (보너스) 사용자가 미전송한 로컬 데이터에 대한 주의 문구 추가

---

## ❓ 의사결정 사항 (Socratic Gate)
- **Q1**: 사용자 앱의 StatSummaryCard를 관리자 앱 내의 별도 폴더에 복사하여 독립적으로 관리할까요? 
    - **A**: (에이전트 제안) 영향도를 최소화하기 위해 관리자 앱 전용 위젯 폴더(lib/features/dashboard/widgets/user_detail/)에 복사하여 관리하는 것을 추천합니다.
- **Q2**: 관리자 화면에서 '특정 응시 이력 삭제' 등의 추가 기능을 원하시나요?
    - **A**: (유저 답변 대기) 현재는 조회 UI 동기화에 집중하는 것으로 계획되어 있습니다.

---

**위 계획서 내용을 검토 부탁드립니다. 승인하시면 작업을 시작하겠습니다!**
