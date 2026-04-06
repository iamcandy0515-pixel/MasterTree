# [제안 A] 이미지 최적화 및 CDN 통합 작업 계획서

## 1. 개요
현재 Supabase Storage에 보관 중인 수목 및 퀴즈 이미지 자산을 **Cloudinary(이미지 최적화 CDN)**로 통합하여, 스토리지 용량 문제 및 모바일 앱의 로드 성능 저하를 동시에 해결하기 위한 전략입니다.

---

## 2. 핵심 목표
1.  **Supabase 스토리지 절감**: 고해상도 이미지를 외부 CDN으로 이관하여 무료 티어 한계 극복.
2.  **로드 속도 10배 개선**: 엣지 서버(Edge Server) 캐싱을 통한 빠른 이미지 응답 속도 확보.
3.  **데이터 소모량 감소**: 환경에 따라 WebP/AVIF로 자동 변환 및 리사이징하여 데이터 절약.
4.  **성능 부하 제거**: 모바일 기기의 메모리 점유율을 낮추기 위한 프록시 레이어 구축.

---

## 3. 단계별 추진 로직

### Phase 1: 기반 설정 (Setup)
*   **환경 구축**: 
    - Cloudinary 무료 계정 생성 및 API Key 발급.
    - `nodejs_admin_api/.env`에 Cloudinary 환경 변수 추가.
*   **공통 유틸리티 구현**: 
    - 원본 URL을 클라우디너리 최적화 URL로 변환하는 `ImageCdnUtil` 클래스 작성.

### Phase 2: 데이터 이관 (Migration)
*   **이관 스크립트 작성**: 
    - `scripts/migrate_to_cloudinary.ts`를 작성하여 `trees`, `quizzes` 버킷의 모든 파일을 Cloudinary로 업로드.
*   **DB URL 업데이트**: 
    - `trees.image_url` 및 `quiz_questions.image_url` 컬럼의 값을 Cloudinary 기반 URL로 일괄 업데이트.

### Phase 3: 백엔드 & 앱 기술 연동 (Integration)
*   **Node.js API 수정**: 
    - 퀴즈 생성 시 업로드 경로를 Supabase가 아닌 Cloudinary로 자동 라우팅.
*   **Flutter 앱 최적화**:
    - `cached_network_image` 패키지를 통해 폰 내부에 2차 캐시 생성.
    - Cloudinary의 동적 리사이징 파라미터(`w_500,f_auto,q_auto`) 적용.

---

## 4. 기대 효과 (추정치)

| 항목 | 현재 (Supabase) | 변경 후 (Cloudinary CDN) | 개선도 |
| :--- | :--- | :--- | :--- |
| **평균 이미지 크기** | 2.5 MB (원본) | 120 KB (WebP/Auto) | **95% 절감** |
| **모바일 로드 시간** | 1.5s ~ 3s | 0.2s 미만 | **최대 15배** |
| **스토리지 비용** | 무료 티어 근접 | 별도 25GB 무료 활용 | **용량 해소** |
| **사용자 만족도** | 이미지 끊김 현상 | 지연 없는 매끄러운 렌딩 | **매우 높음** |

---

## 5. 즉시 실행 가능한 액션 아이템
1.  **[ ]** Cloudinary 계정 정보(Cloud Name, API Key) 준비.
2.  **[ ]** `scripts/migrate_to_cloudinary.ts` 실행하여 기존 1,000여 개 리소스 자동 백업.
3.  **[ ]** Flutter `Image` 위젯을 `CachedNetworkImage`로 일괄 교체.

> [!NOTE]
> 이 계획은 기존 데이터의 삭제 없이 병행 운영하며 안정성을 검증한 후, 최종적으로 Supabase 스토리지를 비우는 순서로 진행됩니다.
