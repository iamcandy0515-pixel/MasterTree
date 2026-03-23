# 📝 Task: BulkExtractionFilterPanel 소스 분리 및 최적화 작업 계획서

## 1. 개요
- **대상 파일**: `d:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib\features\quiz_management\screens\widgets\bulk_extraction\bulk_extraction_filter_panel.dart` (257라인)
- **목적**: 
    - `DEVELOPMENT_RULES.md` 1-1 원칙(200줄 제한)에 따른 소스 분할
    - 모바일 부하 감소를 위한 렌더링 최적화 및 기능별 구조화
    - 관리자 앱의 퀴즈 추출 기능 유지보수성 향상

## 2. 사전 체크리스트 (DEVELOPMENT_RULES 0-1, 0-2)
- [ ] 현재 작업 상태 Git 백업 (Stash 또는 Commit)
- [ ] 터미널 인코딩 설정 확인 (`chcp 65001`)
- [ ] `flutter_admin_app` 프로젝트 린트 상태 사전 분석

## 3. 세부 작업 단계 (To-Do List)

### Phase 1: 컴포넌트 분할 설계 (Rule 1-1)
- [ ] `parts/` 서브 디렉토리 생성: `.../widgets/bulk_extraction/parts/`
- [ ] **파일 1**: `file_id_input.dart` 추출 (파일 ID/명 검색 입력 필드)
- [ ] **파일 2**: `exam_category_dropdowns.dart` 추출 (과목, 연도, 회차 드롭다운 선택기)
- [ ] **파일 3**: `extraction_range_inputs.dart` 추출 (문제 시작/종료 범위 입력)
- [ ] **파일 4**: `extract_action_button.dart` 추출 (추출 버튼 및 상태 처리)

### Phase 2: 부모-자식 위젯 간 효율적 통신 구현 (Rule 1-2)
- [ ] 각 분리된 위젯으로 필요한 콜백(Callback) 매개변수 정의 및 전달
- [ ] `const` 생성자를 활용하여 불필요한 위젯 트리 재빌드 원천 차단
- [ ] 입력값 변경 시 해당 위젯만 업데이트되도록 상태 관리 최적화

### Phase 3: 에러 사전 예방 및 UI 정합성 체크 (Rule 1-3, 0-3)
- [ ] 분리 후 Import 경로 유효성 최종 확인 (파일 경로 이슈 대응)
- [ ] 작은 모바일 화면에서 드롭다운이나 입력 필드가 겹치지 않는지(Overflow) 레이아웃 재검증
- [ ] 리팩토링 후 기존 스타일(색상, 폰트 크기 등) 일치 여부 확인

### Phase 4: 최종 검토 및 빌드 완결성 (Rule 3-2, 2-3)
- [ ] `flutter analyze` 실행하여 모든 경고 및 오류 해결
- [ ] 퀴즈 추출 기능이 기존과 동일하게 동작하는지 기능 테스트 수행
- [ ] 작업 완료 후 소스 차이(diff) 최종 분석 및 보고

## 4. 기대 효과 및 향후 제안
- **성능**: 위젯이 작게 쪼개져 모바일 CPU 가비지 컬렉션(GC) 시 부담 감소
- **가독성**: 257라인의 monolithic 코드를 100라인 이내로 축소 (각 분할 파일은 30~50라인 수준)
- **확장성**: 향후 퀴즈 관리의 다른 화면에서도 동일한 필터 위젯 재사용 가능
