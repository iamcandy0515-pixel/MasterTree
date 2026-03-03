-- 📌 Migration Script: Create Quiz Schema
-- Purpose: Add tables for Quiz Learning App feature (categories, exams, questions, sessions, attempts)

-- ==============================================================================
-- 1. TABLE CREATION
-- ==============================================================================

-- 1) Quiz Categories
CREATE TABLE IF NOT EXISTS public.quiz_categories (
  id bigint generated always as identity primary key,
  name text not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2) Quiz Exams
CREATE TABLE IF NOT EXISTS public.quiz_exams (
  id bigint generated always as identity primary key,
  year int not null,
  round int not null,
  title text not null,
  is_published boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3) Quiz Questions
CREATE TABLE IF NOT EXISTS public.quiz_questions (
  id bigint generated always as identity primary key,
  exam_id bigint references public.quiz_exams(id) on delete cascade,
  category_id bigint references public.quiz_categories(id) on delete set null,
  raw_source_text text,
  raw_source_image_url text,
  content_blocks jsonb default '[]'::jsonb not null,
  hint_blocks jsonb default '[]'::jsonb not null,
  options jsonb default '[]'::jsonb not null,
  correct_option_index int,
  explanation_blocks jsonb default '[]'::jsonb not null,
  difficulty int default 1,
  status text default 'draft' check (status in ('draft', 'published', 'archived')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4) Quiz Sessions
CREATE TABLE IF NOT EXISTS public.quiz_sessions (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  mode text, -- 'normal', 'random', etc.
  correct_count int default 0,
  total_questions int default 0,
  started_at timestamp with time zone default timezone('utc'::text, now()) not null,
  finished_at timestamp with time zone
);

-- 5) Quiz Attempts
CREATE TABLE IF NOT EXISTS public.quiz_attempts (
  id bigint generated always as identity primary key,
  session_id bigint references public.quiz_sessions(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  question_id bigint references public.quiz_questions(id) on delete cascade not null,
  category_id bigint references public.quiz_categories(id) on delete set null,
  is_correct boolean not null,
  user_answer text,
  time_taken_ms int,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ==============================================================================
-- 2. RLS POLICIES (Row Level Security)
-- ==============================================================================

-- Enable RLS for all tables
ALTER TABLE public.quiz_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;

-- 1) Quiz Categories Policies (Public Read, Admin Write)
DROP POLICY IF EXISTS "Quiz Categories Read All" ON public.quiz_categories;
DROP POLICY IF EXISTS "Quiz Categories Insert Admin" ON public.quiz_categories;
DROP POLICY IF EXISTS "Quiz Categories Update Admin" ON public.quiz_categories;
DROP POLICY IF EXISTS "Quiz Categories Delete Admin" ON public.quiz_categories;

CREATE POLICY "Quiz Categories Read All" ON public.quiz_categories FOR SELECT USING (true);
CREATE POLICY "Quiz Categories Insert Admin" ON public.quiz_categories FOR INSERT WITH CHECK (
  exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Categories Update Admin" ON public.quiz_categories FOR UPDATE USING (
  exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Categories Delete Admin" ON public.quiz_categories FOR DELETE USING (
  exists (select 1 from public.admins where user_id = auth.uid())
);

-- 2) Quiz Exams Policies (Public Read, Admin Write)
DROP POLICY IF EXISTS "Quiz Exams Read All" ON public.quiz_exams;
DROP POLICY IF EXISTS "Quiz Exams Insert Admin" ON public.quiz_exams;
DROP POLICY IF EXISTS "Quiz Exams Update Admin" ON public.quiz_exams;
DROP POLICY IF EXISTS "Quiz Exams Delete Admin" ON public.quiz_exams;

CREATE POLICY "Quiz Exams Read All" ON public.quiz_exams FOR SELECT USING (true);
CREATE POLICY "Quiz Exams Insert Admin" ON public.quiz_exams FOR INSERT WITH CHECK (
  exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Exams Update Admin" ON public.quiz_exams FOR UPDATE USING (
  exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Exams Delete Admin" ON public.quiz_exams FOR DELETE USING (
  exists (select 1 from public.admins where user_id = auth.uid())
);

-- 3) Quiz Questions Policies (Public Read, Admin Write)
DROP POLICY IF EXISTS "Quiz Questions Read All" ON public.quiz_questions;
DROP POLICY IF EXISTS "Quiz Questions Insert Admin" ON public.quiz_questions;
DROP POLICY IF EXISTS "Quiz Questions Update Admin" ON public.quiz_questions;
DROP POLICY IF EXISTS "Quiz Questions Delete Admin" ON public.quiz_questions;

CREATE POLICY "Quiz Questions Read All" ON public.quiz_questions FOR SELECT USING (true);
CREATE POLICY "Quiz Questions Insert Admin" ON public.quiz_questions FOR INSERT WITH CHECK (
  exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Questions Update Admin" ON public.quiz_questions FOR UPDATE USING (
  exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Questions Delete Admin" ON public.quiz_questions FOR DELETE USING (
  exists (select 1 from public.admins where user_id = auth.uid())
);

-- 4) Quiz Sessions Policies (Owner & Admin Access)
DROP POLICY IF EXISTS "Quiz Sessions Owner Select" ON public.quiz_sessions;
DROP POLICY IF EXISTS "Quiz Sessions Owner Insert" ON public.quiz_sessions;
DROP POLICY IF EXISTS "Quiz Sessions Owner Update" ON public.quiz_sessions;
DROP POLICY IF EXISTS "Quiz Sessions Owner Delete" ON public.quiz_sessions;
DROP POLICY IF EXISTS "Quiz Sessions Select" ON public.quiz_sessions;
DROP POLICY IF EXISTS "Quiz Sessions Insert" ON public.quiz_sessions;
DROP POLICY IF EXISTS "Quiz Sessions Update" ON public.quiz_sessions;
DROP POLICY IF EXISTS "Quiz Sessions Delete" ON public.quiz_sessions;

CREATE POLICY "Quiz Sessions Select" ON public.quiz_sessions FOR SELECT USING (
  auth.uid() = user_id OR exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Sessions Insert" ON public.quiz_sessions FOR INSERT WITH CHECK (
  auth.uid() = user_id OR exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Sessions Update" ON public.quiz_sessions FOR UPDATE USING (
  auth.uid() = user_id OR exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Sessions Delete" ON public.quiz_sessions FOR DELETE USING (
  auth.uid() = user_id OR exists (select 1 from public.admins where user_id = auth.uid())
);

-- 5) Quiz Attempts Policies (Owner & Admin Access)
DROP POLICY IF EXISTS "Quiz Attempts Owner Select" ON public.quiz_attempts;
DROP POLICY IF EXISTS "Quiz Attempts Owner Insert" ON public.quiz_attempts;
DROP POLICY IF EXISTS "Quiz Attempts Owner Update" ON public.quiz_attempts;
DROP POLICY IF EXISTS "Quiz Attempts Owner Delete" ON public.quiz_attempts;
DROP POLICY IF EXISTS "Quiz Attempts Select" ON public.quiz_attempts;
DROP POLICY IF EXISTS "Quiz Attempts Insert" ON public.quiz_attempts;
DROP POLICY IF EXISTS "Quiz Attempts Update" ON public.quiz_attempts;
DROP POLICY IF EXISTS "Quiz Attempts Delete" ON public.quiz_attempts;

CREATE POLICY "Quiz Attempts Select" ON public.quiz_attempts FOR SELECT USING (
  auth.uid() = user_id OR exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Attempts Insert" ON public.quiz_attempts FOR INSERT WITH CHECK (
  auth.uid() = user_id OR exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Attempts Update" ON public.quiz_attempts FOR UPDATE USING (
  auth.uid() = user_id OR exists (select 1 from public.admins where user_id = auth.uid())
);
CREATE POLICY "Quiz Attempts Delete" ON public.quiz_attempts FOR DELETE USING (
  auth.uid() = user_id OR exists (select 1 from public.admins where user_id = auth.uid())
);

-- ==============================================================================
-- 3. VERIFICATION (Optional)
-- ==============================================================================
-- Check if tables exist
-- SELECT table_name 
-- FROM information_schema.tables 
-- WHERE table_schema = 'public' AND table_name LIKE 'quiz_%';
