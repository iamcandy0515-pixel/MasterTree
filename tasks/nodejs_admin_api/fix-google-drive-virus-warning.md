# Task: Google Drive 바이러스 검사 경고 우회 및 이미지 복구

## 1. 개요

6.8MB 이상의 대용량 이미지를 구글 드라이브에서 가져올 때 발생하는 "바이러스 검사 경고" 페이지를 우회하도록 백엔드 로직을 수정하고, 손상된 '신갈나무' 꽃 이미지를 정상화합니다.

## 2. 작업 범위

- **서비스**: `nodejs_admin_api`
- **파일**: `src/modules/external/google_drive.service.ts`
- **대상**: `downloadFileAsBuffer` 함수 개선

## 3. 세부 작업 단계 (완료)

### Phase 1: 백엔드 로직 수정 (완료)

1. `downloadFileAsBuffer` 함수에서 HTML 응답 감지 로직 추가.
2. `confirm=xxxx` 토큰을 정규식으로 추출하여 경고를 우회하고 실제 파일을 다운로드하는 재시도 로직 구현.

### Phase 2: 이미지 복구 및 검증 (완료)

1. 복구 전용 스크립트 실행: `npx ts-node src/repair_shingal_flower.ts`
2. 결과: **7.1MB**의 정상 이미지 바이너리 획득 및 Supabase 재업로드 성공.
3. DB 업데이트: '신갈나무' 꽃 이미지 레코드(ID: 1327)의 URL 교체 완료.

## 4. 최종 결과

- **정상 파일 크기**: 7,111,942 bytes (기존 손상된 HTML은 약 70KB 미만이었음)
- **복구된 URL**: [신갈나무 꽃 이미지](https://phqnxvehlcvruaavquay.supabase.co/storage/v1/object/public/tree-images/trees/1773130508646_repair_shingal_flower.jpg)

## 5. 사후 점검 및 리스크 분석 (Review)

- **잠재적 이슈**: 구글 드라이브의 "confirm" 방식은 비공식 경로이므로, 구글의 보안 정책이 강화되어 HTML 구조가 변경되면 토큰 추출이 실패할 수 있습니다.
- **대응 방안**: 만약 향후 대용량 파일 다운로드 오류가 재발할 경우, Google Drive API의 정식 OAuth2 인증 과정을 강화하거나, 파일 업로드 시 클라이언트 측에서 직접 드라이브 API를 호출하는 방식을 검토해야 합니다.
- **성능**: 재시도 로직으로 인해 대용량 파일의 경우 첫 응답 속도가 약간 느려질 수 있으나, 데이터 정합성 면에서는 필수적인 조치입니다.
