# 🧩 Task: 사용자 대시보드 리팩토링 및 모바일 최적화

## 📋 개요
사용자 앱의 대시보드 UI를 개선하고, 명칭을 일원화하며, 모바일 환경에 최적화된 구조로 리팩토링합니다. (200줄 제한 준수)

## 🛠️ To-Do List

### Phase 1: 사전 작업 및 명칭 일원화
- [ ] 작업 계획서 생성 (`tasks/refactor-user-dashboard.md`)
- [ ] 전역 상수 또는 하드코딩된 텍스트 명칭 변경
    - '수목 도감' -> '수목도감 일람'
    - '유사(혼돈)수목' -> '비교 수목 일람'
    - '유사 수목 상세' -> '비교 수목 상세'
    - '기출문제 상세' -> '기출/학습 상세(퀴즈)'
- [ ] 대시보드 제목 변경: '사용자 대시보드' (서브: 'Master Tree User')
- [ ] 뒤로가기 아이콘 위치 조정 (타이틀 좌측)

### Phase 2: 소스 분리 (Source Splitting)
- [ ] `DashboardScreen` 분리 (widgets 폴더 생성)
    - [ ] `DashboardHeader` 위젯 추출
    - [ ] `StatSection` 위젯 추출
    - [ ] `ModuleGrid` 위젯 추출
- [ ] 하단 네비게이션바 3버튼화 (`기출/퀴즈`, `수목/퀴즈`, `통계`)

### Phase 3: 수목도감 화면 고도화 및 최적화
- [ ] `TreeListScreen` 소스 분리 (200줄 준수)
- [ ] 필터 시스템 변경: Chips -> 2개의 콤보박스 (Dropdown)
    - '침엽·활엽' (전체/침엽/활엽)
    - '상록·낙엽' (전체/상록/낙엽)
- [ ] 수목 상세 모달(`showModalBottomSheet`) 구현 및 연동

### Phase 4: 성능 최적화 (Load Balancing & Lightweight)
- [ ] 이미지 로드 시 `cacheWidth` 적용 (메모리 절감)
- [ ] 통계 섹션 `ValueNotifier` 기반 부분 렌더링 적용
- [ ] 상세 모달 데이터 지연 로딩 적용

### Phase 5: 최종 검증
- [ ] `flutter analyze` 린트 체크
- [ ] Android 빌드 확인 및 UI Overflow 체크
- [ ] 작업 완료 보고 및 최종 Git 커밋

---
## 📝 작업 기록
- 2026-03-14: 작업 계획서 초안 작성 및 사전 Git 백업 완료.
