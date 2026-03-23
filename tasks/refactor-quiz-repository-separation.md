# 🧩 작업 계획서: Quiz Repository 구조 현대화 및 모듈화 (Rev. 2)

이 문서는 `quiz_repository.dart`의 200라인 초과 이슈를 해결하고, `DEVELOPMENT_RULES.md`를 준수하며 AI/Drive/Storage 기능을 전문화된 저장소로 분리하여 성능 및 유지보수성을 극대화하기 위한 상세 계획입니다.

## 1. 분석 및 문제 정의 (Analysis)
### 1.1 현상 파악 (Current State)
- **파일 경로**: `lib/features/quiz_management/repositories/quiz_repository.dart`
- **파일 크기**: **346라인** (규칙 1-1. 200줄 제한 위반)
- **주요 병목**:
    - AI 생성(Gen), Drive 연동(External), Media 업로드(Upload), CRUD(DB) 로직이 한 파일에 밀집됨.
    - 공통 에러 핸들링 및 디코딩 로직이 중복되어 코드의 명확성 저하.
    - 빈번한 리포지토리 메서드 호출(검색 등) 시 네트워크 오버헤드 발생.

### 1.2 확정된 전략 (Selected Strategy)
1. **각기 상속 (Individual Inheritance)**: AI, Drive, Media, Core 기능을 4개의 독립된 `BaseRepository` 상속 객체로 분리하여 결합도를 낮춤.
2. **Mixin 기반 에러 핸들러 도입**: 모든 리포지토리에 적용 가능한 `QuizRepositoryMixin`을 생성하여 에러 처리 및 응답 파싱 로직을 표준화함.
3. **선택적 캐싱 (Selective Caching)**: 구글 드라이브 검색 결과 및 AI 생성 결과(힌트, 오답 등)를 메모리에 임시 캐싱하여 모바일 로드 부하 절감.

---

## 2. 상세 작업 단계 (Execution Phases)

### Phase 1: 전문 리포지토리 및 공통 믹스인 구축
- **1-1. [0-1. Git 백업]** 작업 시작 전 현재 상태 커밋.
- **1-2. 공통 믹스인 제작**: `lib/features/quiz_management/repositories/quiz_repository_mixin.dart` 생성.
    - `handleResponseError()`: 응답 코드 및 바디 기반 통합 에러 처리.
    - `parseJsonResponse()`: UTF-8 디코딩 및 성공 여부 체크 로직 포함.
- **1-3. 전문 리포지토리 생성**:
    - `quiz_ai_repository.dart`: 힌트/오답 생성, 검수, 추천 로직 분리 (AI 최적화).
    - `quiz_drive_repository.dart`: 드라이브 검색(캐싱 적용), 검증, 추출 로직 분리.
    - `quiz_media_repository.dart`: 이미지 업로드 로직 분리.

### Phase 2: Core 리포지토리 슬림화 및 캐싱 시스템 통합
- **2-1. QuizRepository 정돈**: `quiz_repository.dart`에는 순수 DB 연동(Upsert/Delete/Batch)만 남기고 코드량을 100라인 이하로 축소 (규칙 1-1 엄수).
- **2-2. 캐싱 로직 구현**: `QuizDriveRepository` 및 `QuizAiRepository` 내부에 `Map<String, dynamic> _cache` 필드와 TTL(선택 사항) 또는 조건부 클리어 로직 적용.

### Phase 3: 최종 검증 및 마무리
- **3-1. [1-3. 분리 후 에러 체크]** 각 기능(추출, AI 생성, 업로드)의 정상 동작 및 에러 핸들링 확인.
- **3-2. [3-2. 린트 체크]** `flutter analyze` 명령어로 품질 검증.
- **3-3. [0-4. 소스 정합성]** `git diff` 분석을 통한 미사용 코드 유실 체크.
- **3-4. [0-2. Git 최종 커밋]** 완료 상태 커밋.

---

## 3. To-Do List (Checklist)

### 구현 전 (Pre-Implementation)
- [ ] **[0-1. Git 백업]** 현재 상태 커밋 (`git commit -m "pre-refactor: backup quiz_repository"`)
- [ ] 각 전문 리포지토리에서 공통으로 사용할 `QuizRepositoryMixin` 설계

### 구현 중 (Implementation)
- [ ] `quiz_repository_mixin.dart` 신규 제작
- [ ] `quiz_ai_repository.dart` 분리
- [ ] `quiz_drive_repository.dart` 분리 및 검색 캐싱 적용
- [ ] `quiz_media_repository.dart` 분리
- [ ] `quiz_repository.dart` 슬림화 (100라인 내외 목표)
- [ ] ViewModel/Service에서 새로운 리포지토리 참조 경로 업데이트

### 구현 후 (Post-Implementation)
- [ ] **[1-3. 분리 후 에러 체크]** AI 힌트 및 드라이브 파일 검색 결과 캐싱 동작 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 수행 및 이슈 해결
- [ ] **[0-4. 소스 정합성]** 최종 소스 diff 확인 및 유실 방지 체크
- [ ] **[0-2. Git 최종 커밋]** 작업 결과 커밋

---

## 4. 기대 효과 (Expected Outcomes)
- **가독성 및 안전성**: 각 리포지토리가 100라인 내외로 축소되어 구조 파악이 용이해지고, 믹스인 기반 에러 처리로 예외 상황에 강해짐.
- **성능 개선**: 캐싱을 통해 불필요한 네트워크 트래픽을 줄이고 사용자에게 더 빠른 응답 제공.
- **확장성**: 향후 드라이브 외의 저장소(Dropbox 등)나 다른 AI 모델 도입 시 기존 코드 수정 없이 리포지토리 확장 가능.
