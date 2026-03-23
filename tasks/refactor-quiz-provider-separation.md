# 🧩 작업계획서: 퀴즈 프로바이더(QuizProvider) 로직 분리 및 최적화

## 1. 개요 (Overview)
- **작업명**: `lib/providers/quiz_provider.dart` 데이터/로직 분리 및 Repository 패턴 도입
- **배경**: 현재 `quiz_provider.dart`가 약 408라인으로, 운영 규칙인 **[1-1. 200줄 제한 원칙]**을 대폭 초과함. API 호출 로직과 대량의 더미 데이터가 섞여 있어 유지보수가 어렵고 메모리 효율이 낮음.
- **담당**: Antigravity (AI Coding Assistant)

## 2. 작업 전제 조건 (Pre-requisites)
- [ ] **[0-1. Git 백업]** 전체 작업 시작 전, 현재 상태를 `git commit` 확인.
- [ ] **[0-2. 환경 설정]** 터미널 인코딩 `chcp 65001` 적용 확인.
- [ ] **[4-1. 버전 준수]** Flutter `3.7.12`, Dart `2.19.6` 환경 유지 및 검증.

## 3. 리팩토링 및 최적화 전략 (Refactoring Strategy)
- **Repository 패턴 도입**: `lib/repositories/quiz_repository.dart`를 생성하여 API 호출, 모델 변환(JSON Parsing), 랜덤 오답 생성 로직을 캡슐화.
- **Fallback 데이터 분리**: 하드코딩된 더미 데이터를 `lib/data/fallback_quiz_data.dart`로 이동하여 코드 가독성 확보.
- **상태 관리 집중**: `QuizProvider`는 순수하게 UI 상태(인덱스, 힌트 표시 여부, 정답 개수 등)와 타이머 로직에만 집중하도록 경량화.
- **성능 최적화**: API 로드 전까지는 불필요한 데이터 파싱을 수행하지 않도록 지연 로딩 설계.

## 4. To-Do List
### Phase 1: 데이터 레이어 추출
- [x] `lib/data/fallback_quiz_data.dart` 생성 (더미 질문 리스트 추출)
- [x] `lib/repositories/quiz_repository.dart` 생성 (API Fetch 및 Question 생성 로직 추출)

### Phase 2: Provider 리팩토링 및 로직 연결
- [x] `QuizProvider` 내 비대 메서드(`_fetchQuestionsFromApi`, `_useDummyData`) 제거
- [x] `QuizRepository` 연동 및 결과 처리 로직 구현
- [x] 힌트/답변 처리 및 타이머 관리 로직 간소화

### Phase 3: 검증 및 최종 점검
- [x] **[1-3. 에러 체크]** 분리 후 퀴즈 레이아웃 브레이킹 및 린트 에러 여부 확인
- [x] **[3-2. 린트 체크]** `flutter analyze` 명령어로 스타일 및 문법 오류 제로(0) 확인 (기존 이슈 제외)
- [x] **[1-2. 효율적 통신]** `notifyListeners()` 최적화 및 로드 부하 절감 여부 확인

## 5. 기대 효과 (Expected Outcomes)
- `QuizProvider` 파일이 **150라인 이내**로 대폭 축소되어 유지보수 용이성 확보.
- 퀴즈 로직이 독립적인 Repository로 분리되어 테스트 가시성 및 코드 재사용성 증대.
- UI와 데이터 로직의 명확한 분리를 통한 아키텍처 완성도 제고.

---
**주의**: 본 계획서는 개발자의 최종 승인 후 구현을 시작합니다.
