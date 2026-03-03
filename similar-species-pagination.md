# Task: 유사종 비교 목록 페이지네이션 구현

## 1. 상태 기록 (Plan)

- **목적**: `SimilarSpeciesListScreen`에 페이지네이션 기능을 추가하여 데이터 관리 효율성을 높이고, 맨 처음/맨 마지막 이동 기능을 포함한 네비게이션 UI를 구현함.
- **작업 범위**:
    1.  `SimilarSpeciesListScreen`을 `StatelessWidget`에서 `StatefulWidget`으로 변경하여 현재 페이지 상태 관리.
    2.  페이지 번호, 맨 처음(`<<`), 이전(`<`), 다음(`>`), 맨 마지막(`>>`) 버튼이 포함된 페이지네이션 UI 모듈 작성.
    3.  현재 표시할 데이터 범위를 페이지 번호에 따라 계산하여 리스트 갱신.
    4.  목표 데이터: 5개씩 페이지당 표시 (총 개수에 대비하여 동적 생성).

---

## 2. 실행 (Execute)

- [ ] `flutter_user_app/lib/screens/similar_species_list_screen.dart` 수정
    - 클래스를 `StatefulWidget`으로 컨버전.
    - `_currentPage`, `_itemsPerPage` 변수 추가.
    - `_buildPagination()` 위젯 추가 및 리스트 하단에 배치.
    - 데이터 슬라이싱 로직 적용.
- [ ] UI 및 페이지 전환 동작 확인.

---

## 3. 사후 점검 (Review)

- **완료된 결과(Result)**:
    - **StatefulWidget 전환**: `SimilarSpeciesListScreen`을 `StatefulWidget`으로 변환하여 실시간 페이지 전환 상태를 관리할 수 있도록 했습니다.
    - **페이지 네비게이터 구현**:
        - 맨 처음(`first_page`), 맨 마지막(`last_page`) 아이콘 버튼을 포함한 풀 내비게이터 바를 구현했습니다.
        - 현재 페이지 번호 강조 및 활성화/비활성화 상태 처리를 적용했습니다.
    - **데이터 슬라이싱**: 한 페이지당 5개의 비교 카드가 표시되도록 로직을 작성했습니다.
- **향후 문제점 및 리스크 분석(Risk Analysis)**:
    - **데이터 동적 로딩**: 현재는 하드코딩된 리스트를 사용 중이나, 추후 Supabase 연동 시 `offset` 기반 쿼리로 전환이 필요합니다.
    - **UI 반응성**: 페이지 버튼이 많아질 경우 가로 스크롤이나 생략 기호(...) 처리가 필요할 수 있습니다.
