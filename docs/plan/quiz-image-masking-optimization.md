# [작업 계획서] 퀴즈 이미지 상/하단 마스킹 및 동정 보존 최적화 (규칙 준수)

**문서 경로**: `d:\MasterTreeApp\tree_app_monorepo\docs\plan\quiz-image-masking-optimization.md`
**작성일**: 2026-04-01

## 0. 작업 전제 (Standard Procedures)
- [ ] **[Git 백업 (0-1)]** 구현 시작 전 로컬 커밋 수행 (`pre-task: backup for quiz masking`).
- [ ] **[환경 확인 (0-2)]** 터미널 인코딩(`chcp 65001`) 및 경로 검증.

## 1. 세부 구현 계획 (Technical Tasks)

### 1.1 데이터 모델 및 핸들러 최적화
- [ ] `flutter_user_app/lib/viewmodels/quiz_data_handler.dart` 수정
    - `image_url` 요청 시 너비를 기존 600px에서 **450px**로 하향 조정 (서버 부하 및 로딩 속도 절감).
    - `thumbnail_url` 데이터 매핑 정합성 확인 (200px 썸네일 확보).

### 1.2 듀얼 마스킹 및 물리 크롭 (UI 컴포넌트)
- [ ] `flutter_user_app/lib/screens/widgets/quiz_parts/quiz_image_display.dart` 수정
    - **[중앙 집중 크롭]**: `Transform.scale(scale: 1.25)`와 `Alignment.center`를 사용하여 상/하단 외곽의 텍스트 영역을 물리적으로 잘라내어 시각적 변별력 보호.
    - **[듀얼 마스킹]**: 상단과 하단에 각각 10~15%의 불투명 그라데이션 필터를 추가하여 미세한 글자 노출까지 완벽 차단.
    - **[식별성 보존]**: 중앙 70~80% 영역은 선명함을 유지하여 수목의 잎이나 수피 특징을 식별('동정')할 수 있게 처리.
    - **[하이브리드 로딩]**: 전송받은 썸네일을 `placeholder`로 띄워 로딩 시각적 공백 최소화.

## 2. 검증 및 마무리 (Quality Assurance)
- [ ] **[코드 정합성 (0-4)]** 수정 전/후 Diff 분석 및 불필요한 코드 변경 유무 확인.
- [ ] **[Lint Check (3-2)]** `flutter analyze` 명령을 통해 정적 분석 및 잠재적 런타임 에러 방지.
- [ ] **[최종 커밋]** 작업 완료 후 기능별 연쇄 커밋 수행.

## 3. 규칙 준수 확인 (Compliance)
- **200줄 제한**: 수정 대상인 `QuizImageDisplay.dart`(현재 120줄)와 `QuizDataHandler.dart`(100줄)는 로직 추가 후에도 200줄을 넘지 않을 것으로 예상되나, 초과 시 별도 파트로 즉시 분리 예정.
