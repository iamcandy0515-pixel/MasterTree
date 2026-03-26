# 📋 작업계획서: 관리자 앱 '비교 수목 상세' 이미지 출력 문제 해결 (admin-preview-fix)

## 1. 개요 및 근본적인 문제 분석 (Root Cause Analysis)

### 📌 문제 현상
- 관리자 앱(`flutter_admin_app`)의 '비교 수목 상세' 화면에서 '미리보기'를 클릭하여도 일부 이미지가 전혀 출력되지 않거나 빈 화면으로 나타남.

### 🔍 근본 원인 (Root Cause)
사용자 앱과 관리자 앱의 이미지 로드 방식을 교차 검증한 결과, **CORS(Cross-Origin Resource Sharing) 정책 위반**이 근본적인 원인입니다.
1. **Google Drive 이미지 직접 호출 시도**: 관리자 앱은 현재 `drive.google.com/uc?export=view&id=...` 형태의 원본 URL을 `CachedNetworkImage`로 직접 렌더링하도록 하드코딩되어 있습니다. 웹(또는 엄격한 보안을 적용받는 모바일 환경)에서는 이 과정에서 CORS 오류가 발생하여 브라우저/엔진 레벨에서 이미지 출력을 차단합니다.
2. **프록시(Proxy) 시스템 미적용**: 사용자 앱은 이 문제를 회피하기 위해 `ApiService.getProxyImageUrl`을 사용하여 백엔드(`nodejs_admin_api`의 `/api/uploads/proxy?url=...`)를 경유하여 이미지를 가져오는 반면, 관리자 앱에는 이 로직이 누락되어 있습니다.
3. **확장 카테고리 누락**: 잎, 수피 등 단일 키워드 외에 `twig`, `stem`, `winter_bud` 등 세분화된 이미지 타입이 매핑에서 스킵되어 데이터가 존재함에도 화면에 끌어오지 못했습니다.

---

## 2. DEVELOPMENT_RULES.md 준수 사항 (Compliance)

본 작업은 `DEVELOPMENT_RULES.md`를 엄격히 준수하여 진행됩니다.
- **[Rule 1-1] 200줄 제한**: `flutter_admin_app/lib/features/trees/models/tree_group.dart` 및 관련 파일 수정 시 단일 파일이 200줄을 넘지 않도록 코드를 간결하게 관리합니다.
- **[Rule 2-1] 작업 계획서 작성**: 본 문서(`tasks/admin-preview-fix.md`)를 통해 진행 상황을 To-Do List로 추적하여 누락을 방지합니다.
- **[Rule 3-2] 린트 체크**: 수정 후 `flutter analyze`를 실행하여 린트 오류가 없는지 확인합니다.
- **[Rule 0-4] diff 점검**: 기능 완료 후 의도치 않은 소스 삭제나 UI 오버플로우가 생기지 않았는지 대조 확인합니다.

---

## 3. 해결 전략 및 작업 내용 (Execution Strategy)

**1. 프록시 URL 연동 (CORS 우회)**
- `TreeGroupMember` 모델에서 이미지를 파싱할 때 `BaseRepository.staticProxyUrl`를 사용하여 모든 구글 드라이브 URL을 프록시 경로로 맵핑(Wrapping)합니다.

**2. 이미지 매핑 테이블 확장 (Data Mapping Table 고도화)**
- 기존의 단편적인 태그를 사용자 앱과 동일하게 확장하여 폴백(Fallback) 보존율을 높입니다.
    - **수피 탭**: `bark`, `branch`, `twig`, `stem` 추가
    - **열매 탭**: `fruit`, `fruit_bud`, `winter_bud`, `bud` 추가

**3. 이미지 게터(Getter) 및 UI 컴포넌트 점검**
- 확대/축소(`InteractiveViewer`) 시에도 문제가 발생하지 않도록 팝업 URL에도 동일하게 프록시가 적용되는지 확인합니다.

---

## 4. To-Do List

- [x] `flutter_admin_app/lib/features/trees/models/tree_group.dart` 수정.
  - [x] 매핑 테이블(`_typeMapping`)에 `branch`, `twig`, `stem`, `fruit_bud`, `winter_bud`, `bud` 키워드 추가.
  - [x] `_ensurePngForPlaceholder` 및 반환 객체에 `BaseRepository.staticProxyUrl` 적용을 위한 import 및 호출 로직 추가.
- [x] 소환된 URL 파싱 시 200줄을 넘어가지 않는지 파일 라인 체크.
- [x] 로컬 테스트 (http://localhost:8081).
  - [x] '박달나무 vs 자작나무' 등 디테일 화면 스크롤, 버튼 클릭 및 전체화면 모달 열어보기 테스트로 오버플로우(Overflow)나 CORS 오류 해결 체크.
- [x] `flutter analyze` 실행하여 린트 오류 점검.
- [x] 작업 완료 후 작업 내용 리뷰.

---
**진행 상태**: 완료 (Completed)
