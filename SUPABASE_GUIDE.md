# 🗄️ Supabase Configuration Guide (Database & Storage)

## 1. 🪣 Storage Setup (Bucket)

### 1.1 Create `tree-images` Bucket

We use Supabase Storage to store tree images. This bucket **MUST be public**.

**SQL Command (Recommended)**:

```sql
-- 1. Create a Public Bucket named 'tree-images'
insert into storage.buckets (id, name, public)
values ('tree-images', 'tree-images', true);

-- 2. Allow Public Read Access (Essential for image loading)
create policy "Public Access"
on storage.objects for select
to public
using ( bucket_id = 'tree-images' );

-- 3. Allow Authenticated Insert (For uploaded from Admin API)
create policy "Authenticated Insert"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'tree-images' );
```

### 1.2 Security Considerations (Production)

> **Current Strategy**: Public Bucket (Dev/MVP Phase)
> **Benefit**: Simple integration, CDN caching, direct URL access.
> **Risk**: Anyone with the URL can view the image. No access control.

**For Production (Optional)**:
If strict access control or hotlinking prevention is required, switch to **Private Bucket + Signed URLs**.

1.  **Change Bucket Setting**: Toggle OFF "Public bucket" in Supabase Dashboard.
2.  **Update Admin API**:
    - Replace `getPublicUrl()` with `createSignedUrl(path, 60)`.
    - Frontend must fetch a fresh URL before rendering (adds backend load).

**Recommendation**: for a public Tree Encyclopedia, **Public Bucket is standard** and more performant. Only switch if sensitive user data is stored.

---

## 2. 🗃️ Database Schema

### 2.1 Role & Features Summary

- **Admin**: Create trees, upload images, save AI detections. (Table: `admins`)
- **User**: Take quizzes, track progress, view stats. (Table: `profiles`)
- **System**: Enforce RLS (Row Level Security) based on roles.

### 2.2 Table Structure (SQL)

Run this first to create the schema.

```sql
-- 1. Profiles (User Extension)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Admins (Admin Role Identification)
create table if not exists public.admins (
  user_id uuid references auth.users(id) on delete cascade primary key,
  role_level int default 1
);

-- 3. Trees (Core Tree Info)
create table if not exists public.trees (
  id bigint generated always as identity primary key,
  name_kr text not null,       -- 소나무
  name_en text,                -- Pinus densiflora
  scientific_name text,        -- 학명
  description text,            -- 설명
  difficulty int default 1,    -- 난이도 (1~5)
  created_by uuid references auth.users(id),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Tree Images (Normalized Image Table)
create table if not exists public.tree_images (
  id bigint generated always as identity primary key,
  tree_id bigint references public.trees(id) on delete cascade not null,
  image_type text check (image_type in ('leaf', 'bark', 'flower', 'fruit', 'bud', 'main', 'full')),
  image_url text,                                                               -- Nullable: allows hints without images
  hint text,                                                                    -- Quiz answer hint
  is_quiz_enabled boolean default true not null,                               -- Quiz activation toggle
  uploaded_by uuid references auth.users(id),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Quiz Sessions (Quiz Run)
create table if not exists public.quiz_sessions (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade,
  mode text default 'normal' check (mode in ('normal', 'review', 'ai')),
  started_at timestamp with time zone default timezone('utc'::text, now()) not null,
  finished_at timestamp with time zone,
  total_questions int default 0,
  correct_count int default 0
);

-- 6. Quiz Answers (Answer Log)
create table if not exists public.quiz_answers (
  id bigint generated always as identity primary key,
  session_id bigint references public.quiz_sessions(id) on delete cascade not null,
  tree_id bigint references public.trees(id) on delete set null,
  user_answer text,
  is_correct boolean not null,
  answered_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 7. AI Detections (AI Analysis Log)
create table if not exists public.ai_detections (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id),
  uploaded_image_url text not null,
  predicted_tree_id bigint references public.trees(id),
  confidence float,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### 2.3 RLS Policies (Security)

Run this **AFTER** creating tables to enforce security.

```sql
-- 1. Profiles (Read: Public, Write: Owner)
alter table public.profiles enable row level security;
create policy "Profiles Read Public" on public.profiles for select using (true);
create policy "Profiles Update Own" on public.profiles for update using (auth.uid() = id);

-- 2. Trees (Read: Public, Write: Admin)
alter table public.trees enable row level security;
create policy "Trees Read All" on public.trees for select using (true);
create policy "Trees Insert Admin" on public.trees for insert with check (
  exists (select 1 from public.admins where user_id = auth.uid())
);

-- 3. Tree Images (Read: Public, Write: Admin)
alter table public.tree_images enable row level security;
create policy "Images Read All" on public.tree_images for select using (true);
create policy "Images Insert Admin" on public.tree_images for insert with check (
  exists (select 1 from public.admins where user_id = auth.uid())
);

-- 4. Quiz Sessions (Owner Only)
alter table public.quiz_sessions enable row level security;
create policy "Quiz Sessions Owner Select" on public.quiz_sessions for select using (auth.uid() = user_id);
create policy "Quiz Sessions Owner Insert" on public.quiz_sessions for insert with check (auth.uid() = user_id);

-- 5. Quiz Answers (Owner Only - via Session)
alter table public.quiz_answers enable row level security;
create policy "Quiz Answers Owner Select" on public.quiz_answers for select using (
  exists (select 1 from public.quiz_sessions where id = session_id and user_id = auth.uid())
);
create policy "Quiz Answers Owner Insert" on public.quiz_answers for insert with check (
  exists (select 1 from public.quiz_sessions where id = session_id and user_id = auth.uid())
);

-- 6. AI Detections (Owner Only)
alter table public.ai_detections enable row level security;
create policy "AI Detections Owner Select" on public.ai_detections for select using (auth.uid() = user_id);
create policy "AI Detections Owner Insert" on public.ai_detections for insert with check (auth.uid() = user_id);
```
