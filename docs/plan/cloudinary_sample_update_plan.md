# 📋 Cloudinary 샘플 연동 및 `quiz_questions` 이미지 필드 업데이트 계획서 (최종본)

본 문서는 Supabase Storage의 `tree-images/quizzes` 리소스를 Cloudinary의 `tree-images/quizzes/` 경로에 실존하는 최적화 이미지와 매핑하여 `quiz_questions` 테이블의 `exam_source_image_url` 컬럼을 업데이트하기 위한 가이드입니다.

---

## 🛠️ 작업 목표
1. **원본 리소스 식별**: Supabase Storage `tree-images/quizzes` 내의 파일명과 대응되는 Cloudinary 파일을 매칭합니다.
2. **Cloudinary 리소스 확보**: Cloudinary **`tree-images/quizzes/`** 경로에 이미 업로드된 실존 리소스를 점검하고 URL을 수집합니다.
3. **최적화 URL 생성**: 수집된 URL에 실시간 최적화 파라미터(`f_auto, q_auto`)를 적용한 표준 포맷을 생성합니다.
4. **DB 필드 업데이트**: `quiz_questions.exam_source_image_url` 컬럼에 최종 매핑된 Cloudinary URL을 1건 샘플링하여 업데이트합니다.

---

## 🚀 상세 실행 단계 (To-Do List)

### 1단계: Supabase vs Cloudinary 매핑 확인
- **Supabase**: `tree-images/quizzes` 폴더 내의 파일 리스팅 (ID 및 파일명 추출).
- **Cloudinary**: **`tree-images/quizzes/`** 폴더 내에서 파일명이 일치하거나 퀴즈 ID와 매칭되는 리소스를 확보합니다.

### 2단계: 최적화 URL 정보 추출
- **표준 URL 포맷**:
  - `https://res.cloudinary.com/[CloudName]/image/upload/f_auto,q_auto/v[Version]/tree-images/quizzes/[FileName]`
- **확보 리소스 예시**: 
  - `https://res.cloudinary.com/dtjwql7ug/image/upload/f_auto,q_auto/v1772340933/tree-images/quizzes/17723409335817_u5s2k7_pasted_image.png`

### 3단계: DB 업데이트 스크립트 작성 (Node.js)
- **샘플 레코드 결정**: `quiz_questions` 테이블 중 해당 이미지 원본을 가진 레코드 1건 선정.
- **실행 로직**:
  ```typescript
  import { supabase } from '../src/config/supabaseClient';
  
  const sampleCloudinaryUrl = 'https://res.cloudinary.com/dtjwql7ug/image/upload/f_auto,q_auto/v1772340933/tree-images/quizzes/17723409335817_u5s2k7_pasted_image.png';
  const targetQuizId = 456; // 샘플 작업 ID

  async function updateExamSource() {
    console.log(`🚀 Updating Quiz ${targetQuizId} with Cloudinary URL...`);
    const { error } = await supabase
      .from('quiz_questions')
      .update({ exam_source_image_url: sampleCloudinaryUrl })
      .eq('id', targetQuizId);
    
    if (error) console.error('❌ DB Update Failed:', error.message);
    else console.log(`✅ Success: Quiz ${targetQuizId} exam_source_image_url updated.`);
  }
  updateExamSource();
  ```

### 4단계: 검증 및 결과 보고
- **SQL 쿼리 검증**: 
  - `SELECT id, exam_source_image_url FROM quiz_questions WHERE id = 456;`
- **화면 렌더링 확인**: 관리자 앱의 상세 퀴즈 정보 화면에서 해당 Cloudinary 이미지가 정상적으로 로드되는지 최종 확인.

---

## ⚠️ 주의 사항
- **경로 무결성**: Supabase와 Cloudinary 양쪽 모두 **`tree-images/quizzes/`** 경로를 동일하게 사용하므로 매핑의 정확성을 유지합니다.
- **데이터 무결성**: 1건의 샘플링 작업을 완료한 후, UI에서 깨짐 현상이 없는지 모바일/웹 두 환경 모두에서 검증 후 일괄 작업을 고려합니다.

---
**상태**: **대기 (최종 경로 수정 완료 - 승인 대기 중)**
