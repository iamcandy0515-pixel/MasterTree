# 📋 Task: 신규수목등록 기능 고도화 및 데이터 매핑 최적화

## 1. 개요 (Overview)
관리자 앱의 '신규수목등록' 화면을 개선하고, 엄격한 입력 검증 및 오프라인/온라인 이미지 소스별 최적화된 저장 로직을 적용합니다.

## 2. 작업 전제 조건
- [ ] 현재 Git 상태 백업 (Commit/Stash)
- [ ] `chcp 65001` 터미널 설정 확인
- [ ] `DEVELOPMENT_RULES.md` 200줄 제한 원칙(Rule 1-1) 준수

## 3. 세부 작업 계획 (Step-by-Step)

### 3.1 UI/UX 레이아웃 개편 및 소스 분리
- [ ] `BasicInfoSection`: '구분' 필드를 왼쪽, '성상' 필드를 오른쪽으로 위치 스왑
- [ ] **선택지 제한**:
    - 구분: `['침엽수', '활엽수']`
    - 성상: `['상록수', '낙엽수']`
- [ ] `smart_tag_image_section.dart` 위젯 분리 (200줄 초과 방지)

### 3.2 데이터 매핑 및 검증 로직 (Error Handling)
- [ ] **저장 시 필독 검증**: '구분'과 '성상'이 선택되지 않았을 경우 에러 메시지 팝업 및 저장 차단
- [ ] **조합 매핑**: `selectedCategory`와 `selectedHabit`을 `,`로 조합(`구분,성상`)하여 DB의 `category` 필드에 할당
- [ ] `tree_images` 상세 매핑: `image_url`, `hint`, `image_type` 항목 정합성 확인

### 3.3 이미지 처리 및 스토리지 이원화
- [ ] **붙여넣기(Ctrl+V)**: 클립보드 이미지 감지 시 구글 드라이브 전용 폴더에 업로드하도록 분기 처리
- [ ] **구글 이미지 추가**: 수목 이미지 검색 및 미리보기/선택 기능 보완

### 3.4 서버 및 DB 검증
- [ ] `nodejs_admin_api`: 구글 드라이브 업로드 서비스 및 등록 컨트롤러 업데이트
- [ ] DB 인서트 결과 최종 확인

## 4. To-Do List
- [ ] `lib/features/tree_registration/screens/widgets/basic_info_section.dart` 수정 (필드 스왑, 선택지 제한)
- [ ] `TreeRegistrationViewModel` 수정 (필수 값 검증 로직, category 조합 문자열 생성)
- [ ] `smart_tag_image_section.dart` 모듈화 및 기능 추가
- [ ] `TreeRegistrationRepository` 업로드 파트 분기 구현
- [ ] 서버 API 안정성 테스트
- [ ] `flutter analyze` 린트 체크

## 5. 예상 리스크 및 대책
- **사용자 입력 누락**: 명확한 Helper Text 및 에러 팝업으로 가이드 제공
- **구글 드라이브 연동**: API 응답 지연을 고려한 비동기 처리 및 로딩 인디케이터 적용
