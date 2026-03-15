# 🧩 Quiz Review Detail Screen 모듈화 및 최적화 작업 계획서 (v2)

본 계획서는 `DEVELOPMENT_RULES.md`를 철저히 준수하여 `quiz_review_detail_screen.dart`의 거대 소스(1,325줄)를 분리하고 최적화하기 위한 전략입니다.

---

## 🧐 1. Socratic Gate (요구사항 확인 및 전략 정의) - Rule 2-2
구현 전 정합성을 위해 다음 3가지 사항에 대해 질문드립니다.
1. **이미지 최적화**: 현재 이미지를 원본으로 로딩하고 있는데, 모바일 성능을 위해 썸네일(Thumbnail) 서비스를 연계하여 로딩 부하를 줄이는 로직을 추가할까요?
2. **컨트롤러 관리**: 10개 이상의 `TextEditingController`가 존재합니다. 이를 ViewModel에서 중앙 집중 관리하여 상태 정합성을 높일까요, 아니면 각 하위 위젯에서 관리하고 콜백으로 통신할까요? (Rule 1-2 관련)
3. **웹 격리**: 현재 소스는 모바일 전용에 가깝습니다. 향후 웹 빌드 호환성을 고려하여 `WebUtils` 추상화 레이어를 미리 적용할까요? (Rule 4-3 관련)

---

## 🛠️ 2. 단계별 작업 To-Do List

### Phase 0: 환경 설정 및 소스 보존 (Rule 0-1, 0-2)
- [ ] 1. **작업 전 백업**: 현재 상태를 Git에 커밋하여 소스 유실 방지
- [ ] 2. **인코딩 설정**: 터미널 실행 전 `chcp 65001` 확인
- [ ] 3. **경로 확인**: 윈도우 환경에 맞는 절대 경로(`d:\MasterTreeApp\...`) 활용 및 검토

### Phase 1: 비즈니스 로직 이관 (ViewModel) - Rule 1-2
- [ ] 4. **`QuizReviewDetailViewModel` 생성**: `lib/features/quiz_management/viewmodels/`에 생성
- [ ] 5. **상태 관리 이관**: `Loading`, `Saving`, `QuizData`, `AI Result` 상태를 ViewModel로 이동
- [ ] 6. **Repository 연동**: `QuizRepository` 호출 로직을 ViewModel로 캡슐화

### Phase 2: 소스 분리 및 200줄 제한 준수 - Rule 1-1, 1-3
- [ ] 7. **`QuizDetailHeader`**: 정보 요약 배너 분리 (약 100줄)
- [ ] 8. **`QuizContentCard`**: 지문 및 이미지 관리 분리 (약 150줄)
- [ ] 9. **`QuizExplanationCard`**: 해설 및 AI 검수 분리 (약 180줄)
- [ ] 10. **`QuizOptionsCard`**: 정답/오답 및 AI 생성 분리 (약 150줄)
- [ ] 11. **`QuizRelatedCard`**: 유사 문제 및 추천 로직 분리 (약 180줄)
- [ ] 12. **`QuizHintCard`**: 힌트 입력 모듈 분리 (약 50줄)

### Phase 3: 인프라 및 보안 설정 - Rule 4-3, 4-4
- [ ] 13. **`WebUtils` 적용**: 이미지 선택 및 업로드 로직에 대해 플랫폼 독립성 확보
- [ ] 14. **빌드 버전 유지**: `Gradle 8.5`, `AGP 8.2.1`, `Kotlin 1.9.22` 준수 확인

### Phase 4: 최종 검증 및 품질 관리 - Rule 2-3, 3-2
- [ ] 15. **린트 분석**: `flutter analyze` 실행 및 'Critical' 에러 0건 확인
- [ ] 16. **빌드 테스트**: `flutter build apk --debug`로 컴파일 무결성 검증
- [ ] 17. **최종 Diff 체크**: 의도치 않은 코드 유실 여부 정합성 최종 확인

---

## ⚠️ 중요 준수 사항
- **승인 전 구현 금지**: 개발자(USER)의 작업 계획 승인 전에는 `Phase 1`을 시작하지 않는다.
- **200줄 원칙**: 어떠한 경우에도 새로 생성되는 위젯/ViewModel 파일은 200줄을 넘지 않게 설계한다.
- **Local Commit**: 각 Phase 완료 시마다 로컬 Git 커밋을 반드시 수행한다.
