# Task: 유사 수목 그룹 편집 화면 최적화 및 대표 이미지 추가

## 목적

관리자 앱의 '유사 수목 그룹 편집' 화면에서 수목 목록 조회 시, 휴먼 에러를 방지하고 시각적 직관성을 극대화하기 위해 각 수목의 '대표 이미지(main)' 썸네일을 추가합니다.
동시에 모바일 시스템 부하 및 메모리 리스크를 고려하여 API 및 UI 최적화 기법을 적용합니다.

## 작업 범위

### 1. Backend (Node.js API) DTO 최적화

- `trees.service.ts`의 수목 목록 조회 `getAll` 함수 또는 그룹 조회용 특수 API 검토.
- 전체 이미지 데이터(JSON/Array) 대신, 가장 중요한 첫 번째 'main' 이미지 1건의 URL만 추출하도록 Query/API DTO 개선하여 JOIN/페이로드 비용 최소화.

### 2. Frontend (Flutter Admin App) Model 업데이트

- `Tree` 데이터 모델 (`tree.dart` 등)에서 리스트용 썸네일 URL을 받을 수 있도록 `thumbnailUrl` 속성 추가 반영 (이미 있다면 재사용 확인).

### 3. Frontend UI (`tree_group_list_screen.dart` 또는 멤버 추가 모달)

- 수목명 앞에 40x40 또는 50x50 크기의 원형 이미지(`CircleAvatar` / `ClipOval`) 배치.
- `cached_network_image`를 활용하여 원격 패치 시의 메모리 관리 및 로딩 UX (Placeholder) 적용.

## Risk Analysis

잠재적으로 예상되는 OOM(Out of Memory)과 렌더링 렉(Jank) 이슈를 `builder`(지연 로딩)와 제한된 사이즈 명시로 방어해야 합니다. 이 작업은 향후 다른 리스트 화면에도 표준화 지침이 될 수 있습니다.
