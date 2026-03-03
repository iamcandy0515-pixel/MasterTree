-- 📌 Migration Script: Add hint and is_quiz_enabled to tree_images
-- Created: 2026-02-08
-- Purpose: Add quiz-related fields to existing tree_images table

-- Step 1: Add new columns
ALTER TABLE public.tree_images 
  ADD COLUMN IF NOT EXISTS hint text,
  ADD COLUMN IF NOT EXISTS is_quiz_enabled boolean DEFAULT true NOT NULL;

-- Step 2: Set default values for existing records (if any)
UPDATE public.tree_images 
SET is_quiz_enabled = true 
WHERE is_quiz_enabled IS NULL;

-- Step 3: Verify changes
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'tree_images'
ORDER BY ordinal_position;
