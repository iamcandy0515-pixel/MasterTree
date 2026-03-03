# 🌲 Tree Seeding Guide

## 📦 파일 구조

```
nodejs_admin_api/
├── scripts/
│   ├── data/
│   │   └── trees_seed_data.json    # 수목 데이터 (JSON)
│   ├── seed_trees.ts                # 기존 간단한 시드 스크립트
│   └── seed_trees_with_images.ts   # 이미지 포함 시드 스크립트 (신규)
└── package.json
```

---

## 🚀 사용 방법

### 1. JSON 데이터 준비

`scripts/data/trees_seed_data.json` 파일에 수목 데이터를 추가하세요.

**예시:**

```json
[
    {
        "수목명": "가문비나무",
        "학명": "Picea jezoensis",
        "설명": "[구분] 침엽수 / 상록 교목\n[성상] 상록 교목, 수고 30~40m...",
        "난이도": 2,
        "카테고리": "침엽수",

        "대표이미지": "https://example.com/images/가문비나무_대표.jpg",

        "잎_힌트": "침엽. 사각형 단면. 가지에 방사형으로 달림.",
        "잎_이미지": "https://example.com/images/가문비나무_잎.jpg",
        "잎_활성화": true,

        "수피_힌트": "회갈색. 얇은 비늘 모양으로 벗겨짐.",
        "수피_이미지": "https://example.com/images/가문비나무_수피.jpg",
        "수피_활성화": true,

        "꽃_힌트": "5월 개화. 자웅동주.",
        "꽃_이미지": "https://example.com/images/가문비나무_꽃.jpg",
        "꽃_활성화": true,

        "열매_힌트": "구과. 원통형이며 아래로 늘어짐.",
        "열매_이미지": "https://example.com/images/가문비나무_열매.jpg",
        "열매_활성화": true,

        "겨울눈_힌트": "",
        "겨울눈_이미지": "",
        "겨울눈_활성화": false
    }
]
```

### 2. 환경 변수 확인

`.env` 파일에 다음 변수가 설정되어 있는지 확인하세요:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-key
```

### 3. 스크립트 실행

```bash
# nodejs_admin_api 디렉토리에서 실행
npm run seed:trees
```

---

## 📊 데이터 매핑

| JSON 필드                     | DB 테이블     | DB 컬럼                  |
| ----------------------------- | ------------- | ------------------------ |
| `수목명`                      | `trees`       | `name_kr`                |
| `학명`                        | `trees`       | `scientific_name`        |
| `설명`                        | `trees`       | `description`            |
| `난이도`                      | `trees`       | `difficulty`             |
| `카테고리`                    | `trees`       | `category`               |
| `대표이미지`                  | `tree_images` | `image_url` (type: main) |
| `잎_이미지`                   | `tree_images` | `image_url` (type: leaf) |
| `잎_힌트`                     | `tree_images` | `hint`                   |
| `잎_활성화`                   | `tree_images` | `is_quiz_enabled`        |
| (수피, 꽃, 열매, 겨울눈 동일) | `tree_images` | (동일 패턴)              |

---

## 🎯 주요 기능

### ✅ 중복 방지

- 이미 존재하는 수목은 자동으로 건너뜁니다 (`name_kr` 기준)

### 📸 이미지 자동 매핑

- 대표, 잎, 수피, 꽃, 열매, 겨울눈 이미지를 자동으로 `tree_images` 테이블에 삽입
- 이미지 URL이 없는 경우 자동으로 제외

### 🎮 퀴즈 설정

- `힌트`와 `활성화` 필드를 통해 퀴즈 기능 제어
- 기본값: `is_quiz_enabled = true`

### 📝 로그 출력

```
🌲 Starting tree seeding with images...
📍 Using Supabase URL: https://...

🔍 Processing: 가문비나무
  ✅ Tree inserted (ID: 123)
  📸 Inserted 5 images
  ✅ 가문비나무 completed!

============================================================
🎉 Seeding Completed!
============================================================
📊 Total Trees: 1
✅ Added: 1
⏭️  Skipped: 0
❌ Errors: 0
============================================================
```

---

## 🔧 트러블슈팅

### 문제: "Data file not found"

**해결:** `scripts/data/trees_seed_data.json` 파일이 존재하는지 확인하세요.

### 문제: "Missing SUPABASE_URL or SUPABASE_SERVICE_KEY"

**해결:** `.env` 파일에 환경 변수가 올바르게 설정되어 있는지 확인하세요.

### 문제: "Error inserting images"

**해결:**

1. Supabase에서 `tree_images` 테이블에 `hint`, `is_quiz_enabled` 컬럼이 추가되었는지 확인
2. 마이그레이션 SQL 실행: `migrations/add_tree_images_quiz_fields.sql`

---

## 📚 추가 정보

- **기존 스크립트**: `seed_trees.ts` (이름만 삽입)
- **신규 스크립트**: `seed_trees_with_images.ts` (이미지 포함)
- **마이그레이션**: `migrations/add_tree_images_quiz_fields.sql`
