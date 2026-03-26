# 📋 작업계획서: 관리자 앱 '비교 수목 상세' 이미지 복구 (사용자 앱 로직 동기화)

## 1. 개요 (Overview)
- **목적**: 관리자 앱의 '비교 수목 상세' 미리보기에서 이미지가 출력되지 않는 문제를 사용자 앱(User App)의 검증된 로직을 이식하여 해결함.
- **핵심 전략**: 구글 드라이브 CORS 이슈를 우회하기 위한 **이미지 프록시(Proxy)** 도입 및 확장된 이미지 타입 매핑 적용.

## 2. 현황 및 사용자 앱 로직 분석 (Analysis of User App Logic)
사용자 앱(`flutter_user_app`)은 다음과 같은 방식으로 이미지를 안정적으로 로드하고 있습니다:
1. **이미지 프록시 사용**: `ApiService.getProxyImageUrl()`을 통해 모든 구글 드라이브 URL을 `http://localhost:4000/api/uploads/proxy?url=...`로 변환하여 로드함.
2. **확장된 타입 매핑**: 단순히 'leaf', 'bark'뿐만 아니라 `branch`, `twig`, `stem` 등 다양한 하위 타입을 특정 카데고리에 포함시킴.
3. **중복 힌트 병합**: 여러 사진에 흩어진 특징(Hint)을 하나로 병합하여 가독성을 높임.

## 3. 해결 방안 (Proposed Solution)

### 3.1. [UI] 관리자 앱 미리보기 UI 개선
- 사용자 앱의 `VisualComparisonSection`과 유사한 레이아웃을 '비교 상세' 미리보기 다이얼로그에 적용.
- 선택된 스마트 태그(잎, 수피, 꽃, 열매)에 따라 좌/우 이미지를 동적으로 교체.

### 3.2. [서버/변수] 프록시 URL 연동
- **환경 변수**: `nodejs_admin_api`의 `.env`에 정의된 `BASE_URL`을 기반으로 프록시 주소 생성.
- **로직 구현**: 관리자 앱의 `BaseRepository` 또는 `TreeGroup` 모델 내부에 `getProxyImageUrl` 유틸리티 추가.

### 3.3. [DB/매핑] 이미지 타입 확장 (Mapping Table 고도화)
- 기존 매핑 테이블에 사용자 앱의 규칙을 추가하여 데이터 보존성 향상:
    - **bark**: `bark`, `branch`, `twig`, `stem` (가느다란 가지나 줄기 포함)
    - **fruit**: `fruit`, `fruit_bud`, `winter_bud`, `bud` (열매 및 겨울눈 포함)

### 3.4. [검증] 구글 드라이브 이미지 존재 여부 체크
- DB에 URL이 존재하더라도 실제 드라이브에서 삭제된 경우를 대비하여, 프록시 서버 연동 시 404 에러 핸들링 및 Placeholder 노출 강화.

## 4. 실행 단계 (Action Items)

- [ ] **Step 1: 관리자 앱 전용 프록시 유틸리티 구현**
    - `lib/core/repositories/base_repository.dart`에 `getProxyUrl(String? url)` 추가.
- [ ] **Step 2: 모델(Models) 업데이트**
    - `TreeGroupMember` 및 `TreeImage` 모델의 `_typeMapping`을 사용자 앱 수준으로 확장.
    - `fromJson` 단계에서 모든 이미지 URL을 프록시 주소로 랩핑(Wrapping).
- [ ] **Step 3: UI 위젯 연동**
    - `LookalikeTreeColumn`에서 `member.leafImageUrl` 등이 프록시 URL을 반환하도록 수정.
- [ ] **Step 4: 데이터 정합성 테스트**
    - '박달나무(ID: 15)'의 `fruit_bud` 데이터가 '열매' 탭에서 정상 노출되는지 최종 확인.

---
**작성자**: Antigravity (Google Deepmind)
**일자**: 2026-03-26
