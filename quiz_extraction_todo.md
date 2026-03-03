# Quiz Extraction Step 2 Refactoring TODO

## 1. Backend Updates (Node.js API)

- [ ] Update `extractQuizFromPdfBuffer` Prompt in `quiz.service.ts`
    - Output languages strictly in Korean.
    - Separate output into `content_blocks` (문제), `explanation_blocks` (정답 및 해설), `hint_blocks` (힌트), `options` (보기/오답 포함).
- [ ] Add `generateHints` in `quiz.service.ts` and `quiz.controller.ts`
    - Takes question text and explanation, outputs new helpful hints.
- [ ] Add `generateDistractors` in `quiz.service.ts` and `quiz.controller.ts`
    - Takes question text and correct answer, outputs plausible wrong options (오답).
- [ ] Add `upsertQuizQuestion` in `quiz.service.ts` and `quiz.controller.ts`
    - Saves the extracted question to the database via Supabase or appropriate DB client.

## 2. Frontend Updates (Flutter Admin App)

- [ ] Refactor `quiz_extraction_step2_screen.dart` UI layout
    - Remove wireframe boxes ('정답과해설', '힌트' placeholder boxes).
    - Add text fields for '문제', '정답 및 해설'.
    - Map `options` to a list with circled numbers (①, ②, ③, ④).
- [ ] Implement '힌트 재추천' and '오답 재추천' Buttons
    - Create button UI and loading states.
    - Implement API calls for these specific generations.
- [ ] Implement 'DB 저장' Button
    - Place it next to '추출 데이터 상세'.
    - Gather all edited data and call the UPSERT API.
    - Show success/failure snackbars.

## 3. Review and Testing

- [ ] Verify Korean extraction via Gemini.
- [ ] Verify `generateHints` and `generateDistractors` correctly update fields.
- [ ] Verify DB insertion matches `public.quiz_questions` schema.
