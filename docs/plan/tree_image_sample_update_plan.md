# 📋 Cloudinary 수목 연동 및 `tree_images.quizz_source_image_url` 업데이트 계획서

본 문서는 Supabase Storage의 `tree-images/tree` 리소스를 Cloudinary의 최적화 이미지 경로와 매핑하여 `tree_images` 테이블의 `quizz_source_image_url` 컬럼을 업데이트하기 위한 가이드입니다.

---

## 🛠️ 작업 목표
1. **Cloudinary 리소스 확보**: Cloudinary `tree-images/trees/` (복수형) 폴더 내 실존하는 이미지 리소스를 확인합니다.
2. **최적화 URL 생성**: 수집된 URL에 실시간 최적화 파라미터(`f_auto, q_auto`)를 적용한 표준 포맷을 생성합니다.
3. **DB 필드 업데이트**: `tree_images.quizz_source_image_url` 컬럼에 최종 매핑된 Cloudinary URL을 업데이트합니다.

---

## 🚀 상세 실행 단계 (To-Do List)

### 1단계: Cloudinary 실존 리소스 리스팅
- **명령어**: Cloudinary API를 통해 `tree-images/trees/` 하위 리소스를 가져옵니다.
- **샘플 리소스 추출**: `tree-images/trees/1770440729436.jpg` (점검 완료된 실제 파일)

### 2단계: 최적화 URL 정보 추출
- **표준 URL 포맷**:
  - `https://res.cloudinary.com/[CloudName]/image/upload/f_auto,q_auto/v[Version]/tree-images/trees/[FileName]`
- **확보 리소스 예시**: 
  - `https://res.cloudinary.com/dtjwql7ug/image/upload/f_auto,q_auto/v1775448647/tree-images/trees/1770440729436.jpg`

### 3단계: DB 업데이트 샘플링 (Node.js)
- **샘플 레코드 결정**: `tree_images` 테이블 중 유효한 수목 레코드 1건 선정.
- **실행 로직**:
  ```typescript
  import { supabase } from '../src/config/supabaseClient';
  
  const sampleCloudinaryUrl = 'https://res.cloudinary.com/dtjwql7ug/image/upload/f_auto,q_auto/v1775448647/tree-images/trees/1770440729436.jpg';
  const targetId = 11; // 샘플 수목 이미지 ID

  async function updateQuizSource() {
    console.log(`🚀 Updating Tree Image ${targetId} with Cloudinary URL...`);
    const { error } = await supabase
      .from('tree_images')
      .update({ quizz_source_image_url: sampleCloudinaryUrl })
      .eq('id', targetId);
    
    if (error) console.error('❌ DB Update Failed:', error.message);
    else console.log(`✅ Success: Tree Image ${targetId} quizz_source_image_url updated.`);
  }
  updateQuizSource();
  ```

### 4단계: 검증 및 모니터링
- **SQL 쿼리 검증**: 
  - `SELECT id, quizz_source_image_url FROM tree_images WHERE quizz_source_image_url IS NOT NULL;`
- **화면 렌더링 확인**: 관리자 앱 수목 관리 화면에서 최적화된 이미지가 지연 없이 출력되는지 확인.

---

## ⚠️ 주의 사항
- **폴더명 오타 주의**: Supabase의 `tree` 경로는 Cloudinary에서 **`trees`** (복수형) 폴더로 통합 관리되고 있으므로 매칭 시 이를 반영해야 합니다.
- **데이터 일관성**: 수목 앱의 특징상 퀴즈 소스 이미지가 고해상도여야 하므로 `q_auto` 옵션을 적극 활용합니다.

---
**상태**: **대기 (수목 경로 반영 완료 - 승인 대기 중)**
