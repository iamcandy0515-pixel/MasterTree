# MasterTreeApp Monorepo

이 저장소는 MasterTreeApp 프로젝트의 전체 소스 코드를 관리하는 모노레포입니다.

## 📁 폴더 구조

- **`flutter_user_app/`**: 사용자용 Flutter 애플리케이션
- **`flutter_admin_app/`**: 관리자용 Flutter 애플리케이션
- **`nodejs_admin_api/`**: 관리자용 Node.js API 서버
- **`.agent/`**: Antigravity Kit (bkit) 에이전트 환경 및 자동화 도구
- **`DEVELOPER_HANDBOOK.md`**: 개발 원칙 및 설치 가이드
- **`STYLE_GUIDE.md`**: 디자인 및 코드 스타일 가이드

## 🚀 시작하기

### 1. 환경 설정

- Flutter SDK (최신 스테이블 버전)
- Node.js (v18+)
- Python (v3.11+) - 에이전트 스크립트 실행용

### 2. 프로젝트 이관

각 폴더에 기존 소스 코드를 배치하거나 새 프로젝트를 시작하세요.

## 🤖 에이전트 명령어

루트에서 다음 명령어를 사용하여 프로젝트를 관리할 수 있습니다:

- `/plan`: 시스템 설계 및 작업 계획
- `/orchestrate`: 여러 에이전트 협업
- `/debug`: 오류 추적 및 해결
