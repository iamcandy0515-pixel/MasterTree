# 🧩 작업계획서: 기출문제 목록 화면(PastExamListScreen) 리팩토링 및 모듈화

## 1. 개요 (Overview)
- **작업명**: `lib/screens/past_exam_list_screen.dart` 소스 코드 분산 및 성능 최적화
- **배경**: 현재 `past_exam_list_screen.dart`는 308라인으로 **[1-1. 200줄 제한 원칙]**을 초과함. 필터링 드롭다운, 하단 페이지 제어, 목록 카드가 한 파일에 집중되어 유지보수가 어렵고 모바일 렌더링 효율이 낮음.

## 2. 작업 전제 조건 (Pre-requisites)
- [ ] **[0-1. Git 백업]** 구현 시작 전 현재 소스 코드의 `git commit` 확인.
- [ ] **[0-2. 환경 설정]** 터미널 인코딩 `chcp 65001` 적용 확인.
- [ ] **[4-1. 버전 준수]** Flutter `3.7.12`, Dart `2.19.6` 환경 유지.

## 3. 리팩토링 및 최적화 전략 (Refactoring Strategy)
- **위젯 레벨 분리**: 드롭다운 헤더, 페이지네이션 바, 결과 목록 카드를 독립 위젯으로 분리하여 각 위젯의 독립성을 확보함.
- **성능 최적화**: 모든 정적 스타일 요소에 `const` 생성자를 적용하고, 필터 변경 시 전체 화면 대신 해당 필터 위젯만 효율적으로 업데이트하도록 구조화. **[3-1. 성능 최적화]**
- **효율적 통신**: **[1-2. 효율적 통신]** 원칙에 따라 `onUpdate`, `onError` 콜백을 활용하여 `PastExamListController`와 화면 간의 상호작용을 단일화함.

## 4. To-Do List
### Phase 1: 하위 위젯 및 컴포넌트 추출
- [x] `lib/screens/past_exam/widgets/exam_filter_header.dart` 구현 (드롭다운 필터 행)
- [x] `lib/screens/past_exam/widgets/exam_quiz_card.dart` 구현 (개별 기출문제 카드)
- [x] `lib/screens/past_exam/widgets/exam_pagination_bar.dart` 구현 (페이지 제어 바)

### Phase 2: 메인 화면 재구성 및 연동
- [x] `PastExamListScreen` 내의 복잡한 빌드 메서드(`_buildDropdown`, `_buildPagination` 등) 제거
- [x] 메인 화면에서 신규 추출한 위젯들을 임포트하여 전체 레이아웃 재구성
- [x] 컨트롤러와 위젯 간의 콜백(setState 전파 등) 로직 정합성 확인

### Phase 3: 검증 및 최종 점검
- [x] **[1-3. 에러 체크]** 필터링 시 데이터 부재(Empty) 상태 및 에러 스낵바 출력 검증
- [x] **[3-2. 린트 체크]** `flutter analyze` 명령어로 스타일 및 문법 오류 제로(0) 확인 (기존 이슈 제외)
- [x] **[0-4. 소스 정합성]** `git diff` 분석을 통해 기존 데이터 필터링 로직이 유지되었는지 최종 확인

## 5. 기대 효과 (Expected Outcomes)
- `PastExamListScreen` 파일이 **150라인 이내**로 축소되어 핵심 구조 파악이 용이해짐.
- 필터 헤더나 페이지네이션 바의 코드 모듈화로 향후 "관리자용 기출문제 관리" 등 다른 목록 화면에서 동일 UI 재사용 가능.
- 페이지 전환 및 필터 선택 시 더 부드러운 애니메이션 및 모바일 친화적 렌더링 성능 확보.

---
**주의**: 본 계획서는 개발자의 최종 승인 후 구현을 시작합니다.
