# 📋 작업 계획서: SettingsScreen 모듈화 및 모바일 최적화 (v2)

본 계획서는 `DEVELOPMENT_RULES.md`를 기반으로, 모바일 환경의 **로드 부하 감소 및 경량화**를 최우선으로 하여 `SettingsScreen`을 리팩토링하기 위한 가이드입니다.

## 🎯 목표
- **모바일 최적화**: 위젯 분리 및 `const` 생성자 활용으로 리빌드 부하 감소 및 성능 최적화
- **경량화**: 불필요한 기능은 삭제 대신 **주석 처리**하여 소스 유지 및 관리 효율 증대
- **신뢰성 있는 UX**: API 동적 호출을 통한 링크 '정상/비정상' 상태 실시간 피드백
- **시인성 강화**: 그림자(Elevation) 및 외곽선(Border)을 활용한 프리미엄 UI 구현

---

## 📅 단계별 To-Do List

### Phase 0: 준비 및 백업 (Rule 0-1)
- [ ] 1. 현재 작업 상태 확인 및 로컬 Git 커밋 (`git add .`, `git commit`)
- [ ] 2. 터미널 인코딩 설정 확인 (`chcp 65001`)

### Phase 1: 소스 경량화 및 위젯 추출 (Rule 1-1)
- [ ] 3. **불필요한 코드 주석 처리**: 현재 사용하지 않거나 중복된 레거시 UI 섹션 식별 후 주석 처리
- [ ] 4. 핵심 위젯 분리 (200줄 이내 가칙 준수)
    - `lib/features/dashboard/widgets/settings_entry_code_card.dart`
    - `lib/features/dashboard/widgets/settings_qr_card.dart`
    - `lib/features/dashboard/widgets/settings_drive_card.dart`
- [ ] 5. **UI 스타일 적용**: 각 카드 위젯에 **Elevation(그림자)** 및 **Border(외곽선)**를 추가하여 섹션 구분 강화

### Phase 2: API 기반 동적 상태 체크 구현
- [ ] 6. **링크 상태 검증 로직**: `SystemSettingsRepository`를 통해 드라이브 URL의 유효성을 체크하는 API 연동
- [ ] 7. **상태 표시 UI**: 검증 결과에 따라 '정상' (Green) / '비정상' (Red) 텍스트를 실시간으로 표시
- [ ] 8. **성능 고려**: 검증 API 호출 시 불필요한 반복 호출을 방지하기 위한 디바운싱(Debouncing) 적용

### Phase 3: 메인 화면 통합 및 모바일 최적화
- [ ] 9. `settings_screen.dart` 재구성: 분리된 위젯을 조합하여 메인 화면 완성
- [ ] 10. **로드 부하 최적화**: `Provider`의 `Selector` 또는 `Consumer`를 부분적으로 활용하여 변경이 없는 위젯의 리빌드 방지
- [ ] 11. **키보드 대응**: 입력 필드 포커스 시 UI Overflow 방지 및 `SingleChildScrollView` 최적화

### Phase 4: 검증 및 코드 품질 관리 (Rule 2-3, 3-2)
- [ ] 12. `flutter analyze` 실행 및 'Critical' 린트 에러 해결
- [ ] 13. 수정 대상 외 코드 유실 및 주석 처리 정합성 최종 Diff 체크
- [ ] 14. 최종 작업 내역 Git 커밋 및 GitHub 푸시

---

## 🛠 주요 구현 가이드 (Constraints)
- **그림자 및 외곽선**: `Card` 위젯 또는 `BoxDecoration`을 사용하여 `elevation: 4.0` 및 `border: Border.all(color: Colors.white10)` 수준으로 적용
- **상태 체크**: URL 입력창 우측/하단에 `Text` 위젯으로 상태값 표시 (`isLoading` 시 스피너 노출)
- **주석 처리 규칙**: 단순히 삭제하지 않고 `// LEGACY: [이유]`와 같이 주석으로 보존하여 추후 복구 가능성 열어둠
- **의존성**: `dart:html` 사용 금지 (Rule 4-3 준수)
