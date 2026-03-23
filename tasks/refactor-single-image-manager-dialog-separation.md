# 🧩 작업 계획서: Single Image Manager Dialog 모듈화 및 위젯 세분화 (Rev. 2)

이 문서는 `single_image_manager_dialog.dart`의 200라인 초과 이슈를 해결하고, 주석 처리된 클립보드 붙여넣기 기능을 완벽히 복구하며, 개별 이미지 타일 단위까지 모듈화하는 리비전 계획입니다.

## 1. 분석 및 문제 정의 (Analysis)
### 1.1 현상 파악 (Current State)
- **파일 경로**: `lib/features/quiz_management/widgets/single_image_manager_dialog.dart`
- **파일 크기**: **327라인** (규칙 1-1. 200줄 제한 위반)
- **주요 병목**:
    - 드랍존(포커스/단축키), 이미지 리스트(스크롤/썸네일), 업로드 로직이 한 곳에 집중됨.
    - 클립보드 붙여넣기(Ctrl+V) 로직이 주석으로 방치되어 기능 부재.
    - `_isUploading` 등 로컬 상태가 비즈니스 로직(ViewModel)과 분리되어 동기화 필요.

### 1.2 확정된 전략 (Selected Strategy)
1. **아이템 단위 세분화 분리 (Granular Modularization)**: 드랍존, 썸네일 리스트, 개별 이미지 타일을 각각 독립된 위젯으로 분리하여 200라인 규칙을 철저히 준수함.
2. **클립보드(Ctrl+V) 기능 정규 활성화 (Clipboard Normalization)**: 주석 처리된 로직을 안정적인 유틸리티로 복구하여 운영 편의성을 극대화함.
3. **ViewModel 연동 로딩 상태 관리 (State Integration)**: `_isUploading`을 제거하고 `QuizExtractionStep2ViewModel`의 업로드 상태와 통합하여 데이터 일관성을 확보함.

---

## 2. 상세 작업 단계 (Execution Phases)

### Phase 1: 하위 위젯 및 전문 콤포넌트 구축
- **1-1. [0-1. Git 백업]** 작업 시작 전 현재 상태 커밋.
- **1-2. 개별 타일 위젯 생성**: `image_thumbnail_tile.dart` (이미지 1개 출력, 삭제 버튼, 전체 화면 연동).
- **1-3. 이미지 리스트 위젯 생성**: `image_thumbnail_list.dart` (가로 스크롤 및 타일 배치).
- **1-4. 드랍존 전용 위젯 생성**: `image_upload_drop_zone.dart` (포커스, 단축키 트리거 전담).
- **1-5. 클립보드 도우미 생성**: `image_clipboard_extension.dart` (클립보드 -> XFile 변환 정규화).

### Phase 2: 다이얼로그 본체 리팩토링 (Slimming)
- **2-1. SingleQuizImageManagerDialog 조립**: 기존 327라인 코드를 제거하고 상위 3개 모듈을 조립하여 100라인 내외로 축소.
- **2-2. ViewModel 연동 최적화**: 로컬 업로드 상태를 제거하고 ViewModel 주도로 업로드 액션을 통합.

### Phase 3: 최종 검증 및 마무리
- **3-1. [1-3. 분리 후 동작 체크]** Ctrl+V 붙여넣기 기능, 갤러리 피킹, 삭제 기능 동작 확인.
- **3-2. [3-2. 린트 체크]** `flutter analyze` 수행 및 이슈 해결.
- **3-3. [0-4. 소스 정합성]** `git diff`를 통한 기능 유실 여부 체크.
- **3-4. [0-2. Git 최종 커밋]** 완료 상태 커밋.

---

## 3. To-Do List (Checklist)

### 구현 전 (Pre-Implementation)
- [ ] **[0-1. Git 백업]** 현재 상태 커밋 (`git commit -m "pre-refactor: backup single_image_manager_dialog"`)
- [ ] `image_picker` 및 `pasteboard`(또는 적절한 라이브러리) 권한 및 연동 설정 확인

### 구현 중 (Implementation)
- [ ] `image_thumbnail_tile.dart` 개발
- [ ] `image_thumbnail_list.dart` 개발
- [ ] `image_upload_drop_zone.dart` 개발
- [ ] `image_clipboard_extension.dart` 개발 (Ctrl+V 복구)
- [ ] `single_image_manager_dialog.dart` 리팩토링 및 슬림화

### 구현 후 (Post-Implementation)
- [ ] **[1-1. 200라인 확인]** 모든 분리된 파일이 200라인 이하인지 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 수행
- [ ] **[0-4. 소스 정합성]** 최종 소스 diff 및 유실 체크
- [ ] **[0-2. Git 최종 커밋]** 작업 결과 커밋

---

## 4. 기대 효과 (Expected Outcomes)
- **운영 효율성**: Ctrl+V 기능 복구로 이미지 등록 작업이 획기적으로 빨라짐.
- **코드 품질**: 단일 책임 원칙 준수로 에러 추적이 쉬워지고 개별 부품(타일, 리스트)의 재사용이 가능함.
- **상태 안정성**: ViewModel 통합 로딩 관리로 데이터 불일치 가능성을 원천 차단.
