# 🌳 관리자 앱 설계서 (Admin App Specification)

본 문서는 MasterTreeApp 관리자 시스템의 주요 화면 구성 및 기능 상세 정의를 담고 있습니다.

---

## 1. 인증 (Auth)

**파일명**: `login_screen.dart`

- **핵심 기능**:
    - 관리자 전용 이메일 로그인
    - Supabase Auth 기반 인증 연동 및 JWT 토큰 관리
    - 비정상 접근 차단 및 세션 관리

## 2. 대시보드 (Dashboard)

**파일명**: `dashboard_screen.dart`

- **핵심 기능**:
    - 관리자 메인 홈 화면
    - 주요 관리 메뉴(수목, 유사수목, 사용자, 이미지 등) 바로가기 제공
    - 시스템 상태 요약 (전체 등록 수목 수, 현재 접속자 수 등 실시간 현황)

## 3. 수목 관리 현황 (Trees)

**파일명**: `tree_list_screen.dart`, `add_tree_screen.dart` 등

- **기능 상세**:
    1. **수목 일람 조회**: 전체 수목 리스트 검색 및 필터링
    2. **기본 정보 등록**:
        - 이름(한글/학명), 수목 설명
        - **퀴즈용 오답 보기 설정** (수동 등록 지원)
        - 대표 이미지 등록
    3. **Item 정보 등록**:
        - 카테고리(침엽수/활엽수 등) 선택 및 수형 선택
        - **카테고리별 힌트(부위별 특징)** 입력
        - 6개 부위별(잎, 꽃, 수피, 열매, 겨울눈, 전체) 이미지 업로드 및 AI 분석 연동

## 4. 유사 수목 관리 (Look-alikes)

**파일명**: `tree_group_management_screen.dart`, `tree_lookalike_detail_screen.dart` 등

- **기능 상세**:
    - 유사 수목 그룹(예: 참나무 6형제) 일람 조회
    1. **유사수목 그룹정보 등록**:
        - 그룹명, 그룹 공통 힌트(차이점 요약 및 핵심 비교 포인트)
    2. **유사수목 Item 정보 등록**:
        - **핵심 비교 부위(주로 잎과 수피)** 중심의 힌트 정보 및 이미지 등록

## 5. 사용자 관리 (User Settings)

- **기능 상세**:
    - **사용자 접속 정보**: 실시간 접속 로그 및 이력 조회
    - **입장코드 관리**: 앱 접근 제어를 위한 입장 코드 생성, 수정, 삭제
    - **QR코드 관리**: 각 입장 코드별 전용 QR 코드 생성 및 이미지 다운로드/공개

## 6. 이미지 수집 (Image Corpus)

- **목표**: 향후 주관식(서술형/단답형) 및 필답형 기출 문제 활용을 위한 고품질 데이터셋 구축
- **기능 상세**:
    - 6개 핵심 카테고리별 분류 관리:
        - **대표(전경), 잎, 꽃, 수피, 열매, 겨울눈**
    - 머신러닝 학습 및 퀴즈 출제용 이미지 선별 및 태깅 기능

---

**최종 업데이트**: 2026-02-09

---

## 7. 화면단위 로직 (Screen-Level Logic)

### 7.1 수목 현황 일람 (Tree List Screen)

**기능 정의**: 전체 수목 데이터를 조회하고, 사용자가 쉽게 찾을 수 있도록 필터링 및 정렬 기능을 제공합니다. 특히 중복된 수목 데이터(예: 동일 이름이나 학명)를 효과적으로 병합하여 보여줍니다.

#### 1) 데이터 조회 및 초기화 (Data Fetching)

- **Trigger**: 화면 진입(`initState`) 또는 새로고침(Pull-to-Refresh) 시
- **API**: `GET /api/trees` (모든 수목 데이터 조회)
- **쿼리**: `SELECT * FROM trees LEFT JOIN tree_images ON ... ORDER BY name_kr`

#### 2) 중복 수목 처리 (Deduplication Logic)

- **목적**: 동일한 이름(`name_kr`)을 가진 수목 데이터를 하나로 병합하여 사용자에게 깔끔한 목록을 제공
- **처리 로직**:
    1. 전체 수목 리스트를 순회하며 `name_kr`를 Key로 하는 Map 생성
    2. **중복 발견 시**:
        - **메타데이터 보존**: 기존 수목 객체의 중요 정보(학명, 설명, 카테고리, 퀴즈 오답 보기, 자동 퀴즈 여부 등)를 유지
        - **이미지 병합**: 기존 이미지 리스트에 새로운 이미지 리스트를 추가(`addAll`)하여 모든 관련 이미지를 한 곳에서 관리
    3. 처리된 `uniqueTrees` 리스트를 이름순으로 정렬하여 UI에 제공

#### 3) 필터링 (Client-side Filtering)

- **검색**: 수목명(`name_kr`) 또는 학명(`scientific_name`)에 검색어 포함 여부 확인 (대소문자 무시)
- **카테고리**:
    - '전체': 필터 없음
    - '침엽수/활엽수': 수목의 `category` 필드 또는 `description`에 해당 키워드가 포함되는지 확인

---

### 7.2 기본 정보 편집 (Basic Info Edit Screen)

**기능 정의**: 선택된 수목의 핵심 메타데이터(이름, 학명, 설명, 카테고리 등)를 수정하고 퀴즈 구성을 설정합니다.

#### 1) 화면 초기화 (Initialization)

- **Trigger**: `initState`
- **로직**:
    - 전달받은 `Tree` 객체의 데이터를 각 `TextEditingController`에 바인딩
    - **카테고리 파싱**: DB에 저장된 `category` 문자열(예: "활엽수 / 낙엽수")을 분석하여 UI의 '침엽수/활엽수' 및 '상록수/낙엽수' Dropdown 초기값을 정확히 설정 (기본값 하드코딩 방지)
    - **퀴즈 설정 로드**: `quizDistractors` 및 `isAutoQuizEnabled` 상태를 복원

#### 2) 저장 처리 (Save Logic)

- **Process**:
    1. **유효성 검사**: 필수 필드(`name_kr`, `category` 등) 입력 확인
    2. **요청 객체 생성**: 수정된 데이터를 담은 `CreateTreeRequest` DTO 생성
    3. **API 호출**: `PUT /api/trees/:id`
    4. **성공 처리**:
        - `_hasSaved` 플래그를 `true`로 설정 (변경 사항 추적)
        - 성공 메시지(Toast) 표시
- **화면 이탈(Navigation Pop)**:
    - 뒤로가기 버튼 클릭 시 `Navigator.pop(context, _hasSaved)` 호출하여 저장 성공 여부를 반환
    - **부모 화면(일람) 반응**: 반환값이 `true`인 경우, `fetchTrees()`를 재호출하여 목록을 즉시 **새로고침(Refresh)** 실행

---

## 8. 아키텍처 및 성능 최적화 전략 (Architecture & Optimization)

### 8.1 UI와 비즈니스 로직 분리 (MVVM Pattern)

**목표**: 앱의 경량화와 유지보수성을 위해 UI 코드와 데이터 처리 로직을 철저히 분리합니다.

- **원칙**:
    - `View (Flutter Widget)`: 오직 화면 렌더링과 사용자 입력 이벤트 전달만 담당합니다. 비즈니스 로직(`if`, `for`, `API 호출` 등)을 포함하지 않습니다.
    - `ViewModel (ChangeNotifier)`: 화면에 필요한 상태(State)를 관리하고, Repository를 호출하여 데이터를 처리합니다.
- **적용 현황 및 계획**:
    - `TreeListScreen`: **적용 완료** (`DashboardViewModel` 사용)
    - `TreeDetailScreen`: **개선 필요** (현재 UI에 로직 혼재 → `TreeDetailViewModel` 도입 예정)

### 8.2 사용자 부하 분산 및 데이터 처리 (Load Optimization)

**목표**: 클라이언트(앱)의 메모리 사용량을 최소화하고, 서버 리소스를 효율적으로 활용합니다.

- **문제점 진단 (AS-IS)**:
    - 현재 앱에서 `getAllTrees`로 모든 데이터를 내려받은 후, 앱 내부에서 중복 제거 및 필터링을 수행 중입니다.
    - **Risk**: 데이터가 증가할수록 앱 속도 저하 및 메모리 부족(OOM) 발생 가능성이 높습니다.
- **개선 전략 (TO-BE)**:
    1. **Server-Side Processing**:
        - **중복 제거(Deduplication)**, **검색**, **필터링** 로직을 Node.js API 서버 또는 Supabase 쿼리 단계로 이관합니다.
        - 앱은 가공된 최종 결과 데이터만 수신합니다.
    2. **Pagination (페이징 처리)**:
        - 한 번에 모든 데이터를 로드하지 않고, 페이지 단위(예: 20개씩)로 끊어서 요청(`limit`, `offset`)합니다.
    3. **Data Caching**:
        - 자주 변하지 않는 메타데이터(카테고리 목록 등)는 로컬 캐싱을 통해 네트워크 요청을 최소화합니다.

---
