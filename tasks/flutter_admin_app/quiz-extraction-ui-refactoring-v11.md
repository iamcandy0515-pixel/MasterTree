# Task: Quiz Extraction - Similar Question Modal & System Stability Refactoring

## 1. ANALYSIS (연구 및 분석)

### 1-1. 요구사항 및 안정성 이슈 분석

- **UI 흐름**: '유사문제 추출' -> 분석 건수 및 [보기] 버튼 노출 -> 모달 내 편집 -> 닫기 후 메인 화면 리스트 업데이트 -> 최종 DB 저장(Upsert).
- **Overflow 방지**: 퀴즈 지문이나 과목명이 길어질 경우 레이아웃이 깨지는 현상 방지 필요.
- **Lint/Import 규정**:
    - `const` 생성자 최적화로 성능 향상 및 린트 에러 방지.
    - `mounted` 체크를 통한 비동기 UI 업데이트 안전성 확보.
    - 프로젝트 패키지 구조에 맞는 명확한 `import` 경로 사용.

## 2. PLANNING (작업 단계별 계획)

### 1단계: UI 명칭 및 추출 로직 개편

- '유사문제 추출' 버튼 및 상태 메시지 영역 구현.
- `Flexible`과 `Overflow.ellipsis`를 적용하여 텍스트 길이에 따른 레이아웃 붕괴 방지.

### 2단계: 최적화된 편집 모달(Dialog) 구현

- `AlertDialog` 내부에 `ListView.separated` 사용 시 `Flexible`로 감싸 스크롤 가능 영역 확보.
- 리스트 내부 카드 디자인에 `Row`와 `Expanded` 조합으로 가로 배율 최적화.

### 3단계: 모달-메인 간 동기화 및 메인 리스트 렌더링

- 모달이 닫힐 때 `ListView.builder`를 통해 메인 화면 하단에 가독성 높은 카드 리스트 노출.
- 중복된 리스트 렌더링 코드를 메서드로 분리하여 유지보수성 향상.

### 4단계: 코드 무결성 검증 (Final Check)

- `dart analyze`를 통한 린트 에러 전수 조사 및 수정.
- 사용되지 않는 `import` 제거 및 상대/절대 경로 혼용 방지.
- 각 비동기 메서드 내 `if (!mounted) return` 가드 로직 필수 적용.

## 3. SOLUTIONING (아키텍처/디자인 제안)

- **Layout Stability**: `ConstrainedBox` 또는 `Flexible`을 적극 활용하여 다양한 화면 크기에서도 Overflow 없는 견고한 UI 구축.
- **Atomic Operations**: `Upsert` 저장 시 전체 페이로드를 원자적으로 전송하여 데이터 부분 누락 방지.

## 4. IMPLEMENTATION (예정 구현 내용)

- [ ] `6_related_question_module.dart`: 버튼 UI, 모달 호출, 메인 리스트 노출 로직 수정.
- [ ] `_showSimilarQuizzesModal`: Overflow 방지 처리가 적용된 다이얼로그 위젯.
- [ ] `7_db_registration_module.dart`: 최종 저장 시 데이터 동기화 확인.

## 5. RISK ANALYSIS (리스크 분석 및 사후 점검)

- **UI Overflow**: 특히 모달창 내에서 리스트가 길어질 때 `SingleChildScrollView` 또는 `ListView`의 높이 제한 설정 실패 시 에러 발생 가능 -> `SizedBox` 또는 `Flexible`로 해결.
- **비동기 예외**: 네트워크 지연 중 위젯이 dispose될 경우 `setState` 호출 시 에러 -> `mounted` 체크로 방어.
- **Compile Error**: 잘못된 `import` 경로나 패키지 충돌 -> 작업 전후로 빌드 테스트 수행.
