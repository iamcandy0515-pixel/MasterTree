# [작업계획서] 신규 수목 등록 모듈 분리 및 레이아웃 고도화 (V1.0)

개발 표준(`DEVELOPMENT_RULES.md`)을 준수하여 설계된 '신규 수목 등록' 기능의 모듈 독립화 및 기능 고도화 계획입니다.

## 🎯 목표 및 핵심 정책
- **기존 필드 재활용**: `difficulty` 필드(int)를 성상(Habit) 정보로 활용 (1: 상록수, 2: 낙엽수)
- **완전 분리**: 기존 `trees` 기능군에서 분리하여 `tree_registration` 독립 모듈로 구축
- **이미지 정책**: 태그 카테고리별(대표, 잎, 수피, 꽃, 열매) 단 1장의 원본 이미지만 허용
- **진입점 최적화**: 대시보드 전용 카드 연결 및 기존 목록 버튼 삭제

---

## 🏗️ To-Do List

### 🛠️ Step 0: 환경 및 데이터 준비
- [ ] 터미널 인코딩 설정 확인 (`chcp 65001`)
- [ ] 작업 대상 파일 백업 확인 (Git Commit 완료)

### 🛰️ Step 1: Backend 모듈 독립화 (Node.js)
- [ ] `nodejs_admin_api/src/modules/tree-registration` 폴더 생성 및 보일러플레이트 작성
- [ ] `tree-registration.controller.ts` 구현: 수목 등록 로직 (입력 데이터 검증 포함)
- [ ] `tree-registration.routes.ts` 구현: `POST /api/tree-registration` 엔드포인트 등록
- [ ] `app.ts`에 신규 모듈 라우트 등록 및 테스트

### 📱 Step 2: Frontend 모듈 독립화 (Flutter)
- [ ] `lib/features/tree_registration` 신규 기능 폴더 생성
- [ ] `models/tree_registration_request.dart` 정의 (성상 데이터 포함)
- [ ] `repositories/tree_registration_repository.dart` 구현 (신설 API 통신)
- [ ] `viewmodels/tree_registration_viewmodel.dart` 구현 (태그별 이미지 및 힌트 상태 관리)
- [ ] `screens/tree_registration_screen.dart` 레이아웃 구현 (UI 로직 분리)

### 🎨 Step 3: 레이아웃 및 스마트 태그 시스템 고도화
- [ ] **필드명 및 UI 변경**:
    - [ ] `한글 이름(필수)` → `수목명`
    - [ ] `난이도` 드롭다운 → `성상(상록수/낙엽수)` 드롭다운 (1, 2 매핑)
- [ ] **퀴즈 오답 설정**: 오답 보기 필드 2개 고정형 레이아웃 적용
- [ ] **Smart Tag System**:
    - [ ] 카테고리(대표, 잎, 수피, 꽃, 열매) 탭 UI 구현
    - [ ] 카테고리당 이미지 1장 + 힌트 필드 1:1 매칭 UI
    - [ ] 이미지 미리보기 및 삭제 기능 (카테고리별 단일 이미지 보장)

### 🔗 Step 4: 대시보드 통합 및 클린업
- [ ] `DashboardScreen`에 '신규 수목 등록' 카드 추가 및 경로 연결
- [ ] `TreeListScreen` 상단 '신규등록' 버튼 삭제 및 기존 `AddTreeScreen` 참조 제거
- [ ] `TreeDetailScreen` (수정 화면)에도 성상 드롭다운 및 2개 오답 로직 일관성 있게 반영 (필요 시)

### ✅ Step 5: 최종 검증 (Verification)
- [ ] `flutter analyze` 린트 에러 체크 및 해결
- [ ] 실제 등록 프로세스 통합 테스트 (이미지 업로드 -> DB 저장 -> 목록 확인)
- [ ] 소스 정합성 및 유실 방지 최종 체크

---

## 💡 구현 참고 사항 (Rule 1-1)
- 각 파일은 200줄을 넘지 않도록 위젯 및 로직을 적극적으로 분리합니다.
- 성상(Habit) 매핑: `Evergreen (상록수) = 1`, `Deciduous (낙엽수) = 2`
