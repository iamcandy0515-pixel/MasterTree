# TODO List: 수목 이미지 통합 정비 및 배치 작업 (Test -> Full)

이 체크리스트는 수목 이미지 데이터와 썸네일을 구글 드라이브와 동기화하고 정규화하는 전 과정을 관리합니다. **1건의 테스트 리딩** 후 성공 시 전체로 확대합니다.

## 🟩 Phase 1: 환경 구성 및 스크립트 구현

- [ ] **1.1 통합 정비 스크립트 작성 (`scripts/sync_all_tree_images.ts`)**
    - [ ] 드라이브 `TreesQuiz` 폴더에서 원본 이미지 검색 로직 구현.
    - [ ] 드라이브 `TreesQuizThumbnail` 폴더에서 썸네일 이름 변경(`drive.files.update`) 로직 구현.
    - [ ] Supabase `tree_images` 테이블의 `image_url` 및 `thumbnail_url` 필드 업데이트 로직 구현.
    - [ ] 테스트 모드(`--test`)와 전체 모드(`--all`) 구분 지원.

## 🟨 Phase 2: 단일 수목 배치 테스트 (1건)

- [ ] **2.1 테스트 대상 선정:** 예) '소나무' (혹은 이미지가 일부 누락된 수목)
- [ ] **2.2 테스트 실행:** `npx ts-node scripts/sync_all_tree_images.ts --test "소나무"`
- [ ] **2.3 결과 검증:**
    - [ ] **원본:** `TreesQuiz`에서 이미지를 찾아 DB `image_url`이 채워졌는지 확인.
    - [ ] **썸네일:** `TreesQuizThumbnail`의 파일명이 `소나무_XX_thumb.webp`로 바뀌었는지 확인.
    - [ ] **DB Sync:** DB의 `thumbnail_url` 필드가 변경된 파일명 주소로 갱신되었는지 확인.
- [ ] **2.4 사용자 보고 및 승인:** 테스트 결과 스크린샷/로그 공유 후 **전체 실행 승인** 받기.

## 🟦 Phase 3: 전체 수목 일괄 실행 (78종)

- [ ] **3.1 전체 실행:** `npx ts-node scripts/sync_all_tree_images.ts --all`
- [ ] **3.2 예외 처리 및 로그 감시:** 검색되지 않는 파일이나 API 제한 발생 시 로그(`sync_error.log`) 기록.
- [ ] **3.3 작업 이력 저장:** 최종 변경 내역을 `sync_history.json`으로 저장.

## ⬜ Phase 4: 최종 점검 및 마감

- [ ] **4.1 데이터 정합성 확인:** DB 쿼리를 통해 `image_url` 및 `thumbnail_url` 누락율 0% 확인.
- [ ] **4.2 관리자 앱 확인:** 실제 앱 상세 화면에서 모든 부위의 이미지가 정상 출력되는지 샘플링 테스트.
- [ ] **4.3 작업 완료 보고:** 최종 성공 건수 및 복구 내역 요약 리포트 제출.

---

**개발자님, 이 TODO List에 맞춰 작업을 진행하겠습니다. 우선 Step 1.1의 스크립트 작성을 시작할까요?**
