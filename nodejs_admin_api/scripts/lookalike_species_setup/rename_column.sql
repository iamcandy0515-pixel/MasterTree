-- Rename column in tree_groups table
ALTER TABLE public.tree_groups RENAME COLUMN name TO group_name;

-- Alternatively, drop and recreate if data loss is acceptable:
-- DROP TABLE IF EXISTS public.tree_groups CASCADE;
-- CREATE TABLE public.tree_groups (...);
