# 다건 기출문제 상세 내 AI 보조 기능 연동

## 1. 목적 및 범위 (Plan)

- **화면 타이틀 및 불필요 요소 제거:** '문제 검수 (ID: 153)' 같은 개발용 타이틀을 사용자 친화적인 '문제 상세내용'으로 고정.
- **AI 유사문제 추천 버튼 추가:** 기존 '유사문제' 항목 옆에 'AI 추천' 버튼을 배치하여, 현재 문제의 내용을 바탕으로 데이터베이스 내 혹은 벡터 기반의 연관 문제(또는 원문 레퍼런스)를 불러오는 UX 제공.
- **AI 보조 툴박스(AI검수, 오답생성, 추천) 실 서비스 통신 구현:** 기존에 `Mock` 동작(Toast만 뜨거나 URL이 하드코딩된 상태)이었던 `_aiReview()`, `_generateDistractors()`, 새롭게 만들어질 `_recommendSimilar()` 3개의 API를 `TreeRepository`를 통해 실제 백엔드 AI 엔진과 통신하도록 연결.

## 2. 작업 내용 (Execute)

- `quiz_review_detail_screen.dart`:
    - `TreeRepository` 의존성 주입. 기존 `dart:convert`, `http` 패키지 등 화면 내에서 직접 파싱하던 불필요한 레거시 임포트를 깔끔하게 청소(Refactor).
    - 화면 상단 `AppBar`의 타이틀을 `const Text('문제 상세내용')`으로 교체.
    - **AI 검수 (`_aiReview`):** `_repository.reviewQuizAlignment`를 호출하고 그 결과(Score, Notes, Suggestions)를 `AlertDialog` 팝업으로 상세히 보여주며, 수정 제안이 있을 경우 즉각 교체할 수 있는 기능(Replace Action)을 구현.
    - **오답 생성 (`_generateDistractors`):** 하드코딩된 로컬호스트 주소를 벗어나 `_repository.generateDistractors`를 이용해 백엔드의 `Gemini` 프롬프트 요청 후 3개의 매력적인 오답값을 받아와 텍스트 필드에 순차 배열.
    - **AI 추천 (`_recommendSimilar`):** `_buildSectionTitle('유사문제')` 옆에 'AI 추천' 버튼을 신설하고, `_repository.recommendRelated`를 통해 1건의 상관도 높은 레퍼런스를 가져와 유사문제 필드에 텍스트 형태로 자동 기입. 로딩 시각적 피드백 제공.

## 3. 사후 점검 (Review)

- **Result:**
    - 사용자는 '기출문제 일람'의 기존 문제를 눌렀을 때 문제 상세 조회(수정) 화면에서 번거로운 검색이나 창 전환 없이, AI를 통해 즉시 해설/정답 문맥을 피드백 받고, 틀린 보기들을 매력적으로 가공하며, 유사출제 내역을 찾아볼 수 있게 되었습니다.
- **Risk Analysis:**
    - AI 요청(`_isReviewing`, `_isGenerating`, `_isRecommending`)은 상태 변수를 따로 두어 로딩 인디케이터(`CircularProgressIndicator`)를 버튼 자리에 표시되게 하여 중복 호출을 막았습니다. 단, AI 추론에 5~10초 가량 지연이 발생할 수 있으므로, 사용자가 팝업이 뜨기 전에 뒤로 가기를 누르는 엣지 케이스(`mounted` 체크) 방어 코드를 모두 분기해두어 에러 크래시는 발생하지 않습니다.
    - `recommendRelated` 의 경우 DB 상황에 따라 추출된 Raw Data가 없을 수도 있는데, 이 경우 추천 실패 메시지를 자연스럽게 띄우며, 프롬프트나 벡터 인덱싱 등 추가 최적화가 백엔드에 보완될 경우 프론트 수정 없이 성능 개선이 이뤄집니다.
