# 🚀 MasterTreeApp Engineering Harness 개선 로드맵

> **분석 목적**: 현재의 모노레포 구조를 넘어, 어떤 환경에서도 즉시 배포 가능하고(Portable), 대규모 데이터와 사용자 부하를 견디며(Scalable), 결함이 사전에 차단되는(Robust) 엔지니어링 생태계를 구축하기 위함입니다.

---

## 1. 파일 분리 및 모듈화 (Source Splitting)
- [x] **도메인 기반 서비스 세분화**: `QuizService` 리팩토링 및 `QuizIdentityService` 분할 완료.
- [ ] **Monorepo Shared Package (`packages/`) 구축**: Flutter Admin/User 앱 공통 모듈 추출.

## 2. 테스트 환경 고도화 (Test Harness)
- [ ] **Node.js 통합 테스트 하네스**: `Jest` + `Supertest` 도입.
- [ ] **Flutter Golden/Widget 테스트**: UI 회귀 방지 도입.
- [ ] **Mocking 시스템 표준화**: Gemini, Supabase Mocking 레이어 구축.

## 3. 환경 이식성 및 인프라 (Environment Harness)
- [ ] **Docker 컨테이너화**: `docker-compose.yml` 구축.
- [ ] **DB 마이그레이션 자동화**: Supabase CLI 마이그레이션 도입.
- [ ] **Setup Script (`bin/setup`)**: 원클릭 설정 스크립트 제공.

## 4. 로드 부하 및 성능 관리 (Scalability Harness)
- [ ] **비동기 작업 큐 (Background Workers)**: `BullMQ` + `Redis` 도입.
- [ ] **캐싱 레이어 (Caching)**: Redis 기반 데이터 캐싱.
- [ ] **Rate Limiting**: AI API 비용 방어용 제한 시스템.

---
