-- Migration: Allow NULL image_url in tree_images table
-- This allows storing hints even when actual images are not yet uploaded

-- Step 1: Make image_url nullable
ALTER TABLE public.tree_images 
ALTER COLUMN image_url DROP NOT NULL;

-- Step 2: Verify the change
-- You can check the table structure after running this migration
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'tree_images' 
  AND table_schema = 'public'
  AND column_name = 'image_url';

-- Expected result: is_nullable should be 'YES'
