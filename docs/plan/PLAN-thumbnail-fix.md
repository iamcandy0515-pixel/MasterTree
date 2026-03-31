# 🌳 수목 썸네일 출력 및 로직 개선 작업계획서 (PLAN-thumbnail-fix.md)

## 1. 개요
현재 관리자앱의 '수목 이미지 추출 상세' 화면에서 썸네일 이미지가 출력되지 않는 문제를 해결하고, DB 및 구글 드라이브 간의 데이터 동기화와 시각적 상태 표시(배지, 경고) 로직을 요구사항에 맞춰 고도화합니다.

## 2. 주요 요구사항 및 해결 방안

| 요구사항 ID | 상세 내용 | 해결 방안 |
| :--- | :--- | :--- |
| **1-1** | DB에서 원본/썸네일 정보 로드 | TreeSourcingViewModel 초기화 시 tree_images 테이블의 데이터를 누락 없이 로드하도록 보완 |
| **1-2** | 설정(Settings) 정보 연동 | 백엔드 getDriveLinks 호출 시 원본 및 썸네일 폴더 ID를 설정 테이블에서 동적으로 조회 |
| **1-3** | 이미지/썸네일 폴더 정보 기반 출력 | NodeApi 프록시를 통해 썸네일은 300px, 원본은 800px로 최적화하여 출력 |
| **1-4** | 실물 부재 시 "없다는 표시" | 이미지를 숨기지 않고 빨간색 테두리 + 경고 아이콘을 중첩하여 상태 명시 |
| **1-5** | "DB 정보" 배지 출력 | DB 소스인 경우 우측 상단에 파란색 'DB 정보' 배지 노출 로직 정밀화 |

## 3. 핵심 수정 내용 (Chain of Thought 기반)

### Phase 1: ViewModel 로직 개선 (Data Layer)
- 파일: tree_sourcing_viewmodel_drive.part.dart
- 수정사항: 
  - syncWithDrive 시 isManual 여부에 관계없이 DB 정보와 구글 정보를 명확히 분리하여 source 맵 업데이트.
  - thumbnailUrl이 있을 경우 _checkExistence를 무조건 실행하여 fileMissing 상태 실시간 갱신.

### Phase 2: UI 위젯 고도화 (Presentation Layer)
- 파일: sourcing_image_slot.dart
- 수정사항:
  - displayItem 결정 로직에서 isMissing일 때 null을 반환하지 않고, 정보를 유지하되 시각적 경고만 추가.
  - _buildSourceBadge에서 요구사항 1-5에 따른 'DB 정보' 텍스트 및 스타일 고정.
  - errorWidget 처리 시 구글 드라이브 권한 또는 파일 삭제 시에도 안내 메시지 출력.

### Phase 3: 품질 검증
- 린트 체크: flutter analyze를 통한 문법 및 스타일 오류 제거.
- 포트 확인: API(5000), Admin App(5050) 간의 통신 무결성 확인.

## 4. 기대 효과
- 사용자가 실제 DB에 저장된 값과 구글 드라이브의 실제 상태를 한눈에 대조 가능.
- 썸네일 출력 누락 해결을 통한 효율적인 수목 이미지 관리 환경 제공.
- 데이터 출처(DB vs Google) 명확화를 통한 운영 실수 방지.

---
**작성일**: 2026-04-01  
**담당**: Antigravity (AI Coding Assistant)
