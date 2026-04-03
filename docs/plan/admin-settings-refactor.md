# 🛠️ 관리자 앱 설정 화면 리팩토링 계획서 (admin-settings-refactor.md)

## 1. 개요
관리자 앱의 '설정' 화면 UI를 간소화하고(TextButton 도입), 사용되지 않는 시스템 제어 섹션을 제거한 뒤 실질적인 운영 도구인 '사용자 알림정보(Notification)' 관리 기능을 추가함. DB는 기존 pp_settings 테이블의 Key-Value 구조를 활용함.

## 2. 상태 기록 (Plan) - [Rule 2-1 준수]

- [x] **[Phase 0] 작업 준비 및 DB 분석** - [Rule 0-1, 0-2]
    - [x] 아티팩트 권한 충돌 방지 및 PowerShell 우회 전략 수립 완료.
    - [x] **Supabase 분석**: pp_settings 테이블을 활용하여 user_notification 키를 신설하기로 결정.
- [ ] **[Phase 1] 기존 섹션 제거 및 신규 섹션 UI 설계**
    - [ ] settings_screen.dart에서 '시스템 설정 및 제어' 섹션 및 SettingsServerControlCard 제거.
    - [ ] 동일 위치에 '사용자 알림정보' 섹션 헤더 및 SettingsNotificationCard(가칭) 배치.
- [ ] **[Phase 2] 버튼 스타일 전면 리팩토링**
    - [ ] SettingsEntryCodeCard, SettingsQrCard, SettingsDriveCard 내부의 ElevatedButton들을 TextButton으로 교체.
    - [ ] NeoTheme 또는 AppColors를 활용하여 TextButton이 배경과 조화를 이루도록 스타일링 (가독성 확보).
- [ ] **[Phase 3] 백엔드 및 위젯 구현 (SettingsNotificationCard)**
    - [ ] **백엔드**: SettingsService에 getUserNotification, updateUserNotification 메서드 추가 (pp_settings 테이블 연동).
    - [ ] **프론트엔드**: 사용자 알림 내용을 입력받는 TextField (Multi-line 지원)와 저장용 TextButton 구현.
- [ ] **[Phase 4] 사후 검증** - [Rule 1-3, 3-2]
    - [ ] lutter analyze를 통한 구문 에러 체크.
    - [ ] 텍스트 필드 입력 시 키보드 가림 현상 또는 UI 깨짐(Overflow) 여부 확인.

## 3. 구현 세부 사항
- **DB Key**: user_notification (value: 텍스트 형식의 알림 내용)
- **버튼 스타일**: TextButton(onPressed: ..., child: Text('저장', style: TextStyle(color: Color(0xFFCCFF00))))
- **알림 섹션**: Card 또는 Container를 활용하여 일관된 디자인 시스템(Dark Green Theme) 유지.

---
**작업 시작 시 이 계획서를 기반으로 단계를 수행함.**
