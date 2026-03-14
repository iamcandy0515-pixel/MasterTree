# [작업계획서] 사용자 앱 UI 리팩토링 및 모바일 최적화

## 1. 개요
사용자 앱의 가독성 향상과 유지보수 효율성을 위해 UI 명칭을 변경하고, 대규모 파일을 소분하며, 모바일 환경에서의 리소스 사용량을 절감하기 위한 최적화를 수행함.

## 2. 주요 작업 내용

### 2.1 명칭 변경 및 UI 개선
- **사용자 대시보드**: 
    - 타이틀: '사용자 대시보드' (Subtitle: Master Tree User)
    - 네비게이션: [기출/퀴즈, 수목/퀴즈, 통계] 3탭 구성
- **수목도감 일람**:
    - 기존 '수목 도감' -> '수목도감 일람'으로 명칭 변경
    - 상단 필터: [침엽·활엽], [상록·낙엽] 2단계 콤보박스 도입
    - 상세 보기: 별도 화면이 아닌 '수목 상세' 타이틀의 모달 바텀 시트로 전환
- **비교 수목 일람/상세**:
    - '유사(혼돈)수목' -> '비교 수목 일람'
    - '유사 수목 상세' -> '비교 수목 상세'
- **기출 / 학습**:
    - '기출문제 일람' -> '기출 / 학습'
    - '기출문제 상세' -> '기출 / 학습 상세'

### 2.2 코드 구조 리팩토링 (200라인 규칙)
- **DashboardScreen**: `DashboardHeader`, `DashboardStatsSection`, `DashboardModuleGrid` 위젯 분리
- **TreeListScreen**: `TreeListHeader`, `TreeListPagination`, `TreeDetailSheet` 위젯 분리
- **SimilarSpeciesListScreen**: `SimilarSpeciesHeader`, `SimilarSpeciesCard` 위젯 분리
- **SpeciesComparisonDetailScreen**: `ComparisonHeader`, `ComparisonDataCard`, `VisualComparisonSection` 위젯 분리

### 2.3 모바일 경량화 및 성능 최적화
- **부분 리빌드 (Reactive UI)**: `ValueNotifier`와 `ValueListenableBuilder`를 사용하여 통계 데이터(`treeCount`, `quizCount` 등) 업데이트 시 해당 영역만 리빌드되도록 최적화.
- **이미지 메모리 캐시 최적화**: 리스트 및 비교 화면에서 `cacheWidth: 500`을 설정하여 GPU 메모리 점유율을 대폭 감소시킴.
- **Lazy Data Loading**: 모달 및 상세 화면 진입 시 필요한 데이터만 호출하도록 API 연동 최적화.

## 3. 적용 규칙
- `DEVELOPMENT_RULES.md`에 정의된 200라인 이내 파일 크기 유지.
- 위젯 분리 시 `widgets/` 하위 폴더 구조 활용.
- 수정 전/후 linter(`flutter analyze`)를 통한 코드 정합성 검증.
- 작업 완료 후 로컬 git 커밋 수행.

---
**작성일**: 2026-03-14
**담당**: Antigravity (AI Coding Assistant)
