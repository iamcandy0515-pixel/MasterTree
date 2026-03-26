# 작업 계획서 v3: 수목 상세 정보 및 부위별 힌트 저장 기능 정상화 (admin-tree-detail-hint-v3)

## 0. 작업 전제 조건 (Prerequisites)
- [ ] **Git 백업**: 모든 구현 시작 전 `git commit`을 통해 현재 상태를 백업한다. (규칙 0-1)
- [ ] **환경 확인**: 터미널 인코딩(`chcp 65001`) 및 절대 경로 사용을 준수한다. (규칙 0-2)

## 1. 개요 및 원인 분석 (Analysis)
### 1.1. 현상 및 원인 (Rule 2-1)
- **원인 1**: 백엔드(`TreeService.update`)에서 이미지 저장 에러를 무시하는 구조 (Silent Failure).
- **원인 2**: 프론트엔드(`TreeDetailViewModel`)에서 저장 후 로컬 상태 업데이트 누락.
- **원인 3**: 이미지가 없는 카테고리의 힌트 매칭 처리 부재.

### 1.2. 해결 전략 (Rule 3-1)
- `tree_images` 테이블의 `image_url=null` 허용 옵션을 활용하여 5대 표준 카테고리(대표, 잎, 수피, 꽃, 열매) 힌트를 1:1 매칭하여 저장.

## 2. 세부 작업 항목 (To-Do List)

### 2.1. 백엔드(Node.js API) 수정
- [ ] **파일**: `nodejs_admin_api/src/modules/trees/trees.service.ts`
- [ ] **내용**: 
    - `update` 메서드 내 `insertImages` 호출 시 에러 체크(`{ error }`) 및 예외 발생 로직 추가.
    - **모듈화 체크 (규칙 1-1)**: 현재 149줄인 `trees.service.ts`가 수정 후 200줄을 초과할 경우 `TreeImageService` 등으로 기능 분리 고려.

### 2.2. 프론트엔드(Flutter Admin) 수정
- [ ] **파일**: `flutter_admin_app/lib/features/trees/viewmodels/tree_detail_viewmodel.dart`
- [ ] **내용**:
    - `saveHints` 메서드 개선: 5개 카테고리 루프를 돌며 이미지가 없는 부위의 힌트도 `imageUrl: null` 객체로 생성하여 전송.
    - 저장 성공 후 서버 반환값으로 `this.tree` 갱신 및 `notifyListeners()` 호출.
    - **린트 준수 (규칙 3-3)**: 수정 후 `flutter analyze`를 통해 경고 제로 유지.

### 2.3. 데이터 무결성 및 검증
- [ ] **정합성 체크 (규칙 0-4)**: 저장 시 `originUrl`이 백엔드로 정확히 전달되는지 확인.
- [ ] **웹 격리 준수 (규칙 4-4)**: 이미지 처리 로직에서 `dart:html` 직접 사용을 배제하고 기존 추상화 레이어 활용.

## 3. 검증 프로세스 (Verification)
- [ ] `flutter analyze` 실행하여 린트 에러 없음 확인.
- [ ] 백엔드 `npm run lint` (TSC) 실행하여 타입 에러 없음 확인.
- [ ] 실기기/에뮬레이터 테스트: 이미지가 없는 부위의 힌트 저장 및 로드 확인.

## 4. 최종 확인 및 배포 준비
- [ ] 작업 완료 후 `git status` 및 `diff` 분석을 통해 불필요한 코드 추가 여부 확인. (규칙 0-4)
