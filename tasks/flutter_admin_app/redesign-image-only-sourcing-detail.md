# Task: [V4] Redesign Image-Only Sourcing Detail Screen (WebP Focus)

'수목 이미지 추출 상세' 화면을 이미지 전용 관리 화면으로 재설계하며, .webp 확장자 기반의 명명 규칙 및 로딩 최적화 설계를 포함합니다.

## 1. 상태 기록 (Plan) - [승인 대기 중]

### 요구사항 및 설계 방향

- **목적**: 원본/썸네일 이미지 관리 전용 (CURD) 및 webp 표준화
- **제거**: 이미지와 무관한 모든 텍스트 필드 (기본 정보, 힌트, 퀴즈 등)
- **포맷 및 명명 규칙**:
    - 형식: `[수목명]_[카테고리]_thumb.webp`
    - 확장자: **.webp** (필수)
    - 카테고리: 대표, 꽃, 수피, 잎, 열매
- **성능 설계**:
    - `Lazy Loading` 및 `CachedNetworkImage` 적용
    - `cacheWidth/Height` 최적화 (300px)로 디코딩 부하 감소
- **기능**:
    - 원본 이용 실시간 썸네일 생성 및 .webp 인코딩 자동 부여
    - '구글연동' 시 파일명 패턴 기반 자동 분류
    - '설정' 메뉴를 통한 썸네일 URL 수동 관리

### 작업 설계

1. **Model/ViewModel**:
    - `FileNameGenerator`: `{nameKr}_{category}_thumb.webp` 규칙 적용
    - `WebpProcessor`: 클라이언트 사이드 webp 리사이징 및 인코딩 구현
2. **UI Component**:
    - `ThumbnailGenerationButton`: .webp 썸네일 생성을 실행하는 전문 버튼
    - `ImageDualSlotWidget`: 원본(Large)과 썸네일(Small/WebP) 대칭 배치
3. **Screen Layout**:
    - 이미지 갤러리 중심의 카드 그리드 레이아웃

## 2. 실행 (Execute) - [승인 후 진행 예정]

- [ ] UI 위젯 전면 교체 및 레이아웃 최적화
- [ ] webp 인코딩 엔진 및 파일명 규칙 엔진 탑재
- [ ] 설정 팝업 및 URL 직접 입력 기능 구현

## 3. 사후 점검 및 리스크 분석 (Review)

- **예상 리스크**:
    - webp 인코딩 시 CPU 일시적 점유율 상승 (Isolate로 해결)
- **해결 방안**:
    - `compute` 메서드를 활용하여 인코딩 중 메인 쓰레드 멈춤 방지
