---
task: "Fix Admin App Thumbnail Overwrite Bug"
status: "planning"
date: "2026-03-11"
---

# 🛠️ 작업 목적

관리자 앱에서 수목 이미지 정보를 저장할 때, 썸네일 URL이 빈 값이나 null인 경우 기존 DB의 유효한 썸네일 정보를 지워버리는 현상을 방지합니다.

# 📋 작업 범위

1. `TreeSourcingViewModel`의 `saveChanges` 로직 수정
    - 저장 전 썸네일 URL 유효성 검사 추가
    - 새 썸네일이 없더라도 기존 유효한 썸네일이 있다면 이를 보존하도록 로직 개선

# 🚀 실행 단계

1. `flutter_admin_app/lib/features/trees/viewmodels/tree_sourcing_viewmodel.dart` 파일 수정
2. `saveChanges` 메서드 내의 `finalThumbUrl` 결정 로직에 방어적 코드 삽입

# 🔍 검증 계획

- 코드 리뷰를 통해 썸네일 필딩의 null/empty 체크가 올바르게 수행되는지 확인
- 기존 썸네일이 있는 상태에서 썸네일 없는 이미지를 저장하려 할 때 기존 데이터가 유지되는지 시뮬레이션 확인

# ⚠️ 리스크 분석 (Risk Analysis)

- 이번 수정으로 인해 발생할 수 있는 잠재적 사이드 이펙트: 의도적으로 썸네일을 삭제해야 하는 경우(극히 드묾) 삭제되지 않을 수 있으나, 현재 시스템에서는 데이터 보존이 더 중요함.
- 성능 저하 요인: 없음.
- 추후 리팩토링 및 확장성 한계점: 없음.
