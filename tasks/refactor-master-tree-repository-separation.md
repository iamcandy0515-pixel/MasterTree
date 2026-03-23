# 🧩 작업 계획서: Master Tree Repository 모듈화 및 기능 기반 분리 (Rev. 2)

이 문서는 `master_tree_repository.dart`의 200라인 초과 이슈를 해결하고, 범용 프록시 로직을 서버 도메인 전체로 확산하며, 페이징 데이터에 메모리 캐싱을 도입하는 리비전 계획입니다.

## 1. 분석 및 문제 정의 (Analysis)
### 1.1 현상 파악 (Current State)
- **파일 경로**: `lib/features/trees/repositories/master_tree_repository.dart`
- **파일 크기**: **323라인** (규칙 1-1. 200줄 제한 위반)
- **주요 병목**:
    - 일반 수목 데이터 CRUD, 이미지 업로드/구글 연동, CSV 입출력이 한 곳에 집중됨.
    - `getProxyUrl`과 같은 공통 이미지 서버 프록시 로직이 특정 리포지토리에 종속됨.
    - 모바일 목록 조회 시마다 동일한 데이터를 반복적으로 서버에 요청하여 성능 저하 우려.

### 1.2 확정된 전략 (Selected Strategy)
1. **3대 전문 리포지토리 분리 (Granular Decomposition)**:
    - `MasterTreeRepository`: 핵심 DB CRUD 및 페이징.
    - `MasterTreeMediaRepository`: 이미지 업로드, 썸네일 생성, 구글 이미지/드라이브 연동.
    - `MasterTreeDataRepository`: CSV 형식의 벌크 데이터 Import/Export.
2. **Proxy Utility 공통화 (Refactoring to Core)**: `getProxyUrl` 로직을 `BaseRepository`로 이동시켜 앱 전역에서 재사용 가능하게 함.
3. **Mixin 기반 메모리 캐싱 도입 (Smart Caching)**: 수목 목록 및 랜덤 조회 결과에 대해 간단한 메모리 캐싱 로직을 추가하여 성능 최적화.

---

## 2. 상세 작업 단계 (Execution Phases)

### Phase 1: 기반 인프라 및 전용 리포지토리 구축
- **1-1. [0-1. Git 백업]** 작업 시작 전 현재 상태 커밋.
- **1-2. 기반 리팩토링**: `getProxyUrl`을 `BaseRepository`로 이동 및 참조 업데이트.
- **1-3. `MasterTreeMediaRepository` 생성**: 이미지 및 외부 서비스 연동 로직 이관 (약 80라인).
- **1-4. `MasterTreeDataRepository` 생성**: CSV 벌크 작업 로직 이관 (약 50라인).
- **1-5. Caching Mixin 생성**: `MasterTreeCacheMixin`을 통해 페이징 결과 메모리 캐싱 로직 구현.

### Phase 2: 코어 리포지토리 슬림화 (Decomposition)
- **2-1. `MasterTreeRepository` 재구성**: 핵심 CRUD만 남기고 `200라인` 이하로 축소 (약 100라인 내외).
- **2-2. 캐싱 적용**: Mixin을 통해 수목 목록 조회부에 캐싱 레이어 적용.

### Phase 3: 최종 검증 및 마무리
- **3-1. [1-3. 분리 후 동작 체크]** 수목 목록, 상세 수정, 이미지 검색, CSV 내보내기 동작 확인.
- **3-2. [3-2. 린트 체크]** `flutter analyze` 수행 및 이슈 해결.
- **3-3. [0-4. 소스 정합성]** `git diff`를 통한 기능 유실 여부 체크.
- **3-4. [0-2. Git 최종 커밋]** 완료 상태 커밋.

---

## 3. To-Do List (Checklist)

### 구현 전 (Pre-Implementation)
- [ ] **[0-1. Git 백업]** 현재 상태 커밋 (`git commit -m "pre-refactor: backup master_tree_repository"`)
- [ ] `BaseRepository`의 확장 하위 구조 확인

### 구현 중 (Implementation)
- [ ] `MasterTreeMediaRepository.dart` 개발 (이미지/드라이브)
- [ ] `MasterTreeDataRepository.dart` 개발 (CSV/벌크)
- [ ] `MasterTreeCacheMixin.dart` 개발 (메모리 캐시)
- [ ] `MasterTreeRepository.dart` 최종 리팩토링 및 캐싱 적용

### 구현 후 (Post-Implementation)
- [ ] **[1-1. 200라인 확인]** 모든 리포지토리 파일이 200라인 이하인지 확인
- [ ] **[3-2. 린트 체크]** `flutter analyze` 수행
- [ ] **[0-4. 소스 정합성]** 최종 소스 diff 및 유실 체크
- [ ] **[0-2. Git 최종 커밋]** 작업 결과 커밋

---

## 4. 기대 효과 (Expected Outcomes)
- **서버 부하 감소**: 캐싱 적용으로 모바일 사용자의 반복적인 네트워크 요청 최소화.
- **재사용성 향상**: 이미지 프록시 로직 공통화로 향후 다른 이미지 처리 작업 생산성 증대.
- **유지보수 용이**: 기능 단위 명확한 분리로 타겟 로직 수정 시 사이드 이펙트 감소.
