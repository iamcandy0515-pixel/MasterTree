# Task: 모바일 성능 및 CDN 최적화 적용

## 1. 목적 (Goal)

- 모바일 환경에서의 이미지 로딩 속도 극대화
- CDN(Content Delivery Network) 효율을 높이기 위한 백엔드 캐싱 전략 강화
- 모바일 데이터 사용량 절감을 위한 대역폭 최적화 기반 마련

## 2. 작업 범위 (Scope)

### 2.1. 백엔드 API (nodejs_admin_api)

- `uploads.controller.ts`: CDN 캐싱을 위한 `Cache-Control` 헤더 최적화 (Long-term caching 적용)
- 프록시 서버의 응답 헤더에 `ETag` 또는 `Immutable` 설정 검토

### 2.2. 인프라 및 가이드 (Documentation)

- Cloudflare 도입을 위한 설정 가이드 작성
- 이미지 리사이징 및 포맷 최적화(WebP) 로드맵 제시

## 3. 실행 단계 (Execution Plan)

- [ ] **Phase 1: 백엔드 캐시 헤더 강화**
    - `max-age`를 1년(31536000초)으로 상향하여 CDN 에지 서버에 장기 보관 유도
    - `public`, `immutable` 지시어 추가
- [ ] **Phase 2: CDN 설정 가이드 제공**
    - 도메인 연결 및 SSL 설정 가이드
    - Cloudflare 'Caching' 및 'Speed' 설정 추천값 정리

## 4. 향후 문제점 및 리스크 분석 (Risk Analysis)

- **캐시 갱신**: 이미지가 변경되었을 때 CDN 캐시를 비워줘야(Purge) 하는 이슈 발생 가능 (수동 Purge 또는 URL에 버전 관리 도입 고려)
- **메모리 사용량**: 스트리밍 방식의 프록시이므로 대규모 동시 접속 시 백엔드 서버의 네트워크 대역폭 모니터링 필요
