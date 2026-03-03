-- =================================================================================
-- Tree Groups Tables Migration
-- =================================================================================

-- 1. Create 'tree_groups' table
CREATE TABLE IF NOT EXISTS public.tree_groups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    group_name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security (RLS) - Optional but recommended
ALTER TABLE public.tree_groups ENABLE ROW LEVEL SECURITY;

-- Creating policies (Adjust as needed, e.g., allow public read, admin write)
-- For now, allowing all for simplicity or match existing pattern
CREATE POLICY "Allow public read access" ON public.tree_groups FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert" ON public.tree_groups FOR INSERT WITH CHECK (auth.role() = 'authenticated' OR auth.role() = 'service_role');
CREATE POLICY "Allow authenticated update" ON public.tree_groups FOR UPDATE USING (auth.role() = 'authenticated' OR auth.role() = 'service_role');
CREATE POLICY "Allow authenticated delete" ON public.tree_groups FOR DELETE USING (auth.role() = 'authenticated' OR auth.role() = 'service_role');


-- 2. Create 'tree_group_members' table
CREATE TABLE IF NOT EXISTS public.tree_group_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    group_id UUID REFERENCES public.tree_groups(id) ON DELETE CASCADE,
    tree_id BIGINT REFERENCES public.trees(id) ON DELETE CASCADE,
    display_order INTEGER,
    key_characteristics TEXT,
    image_url TEXT, -- Optional override image
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.tree_group_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON public.tree_group_members FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert" ON public.tree_group_members FOR INSERT WITH CHECK (auth.role() = 'authenticated' OR auth.role() = 'service_role');
CREATE POLICY "Allow authenticated update" ON public.tree_group_members FOR UPDATE USING (auth.role() = 'authenticated' OR auth.role() = 'service_role');
CREATE POLICY "Allow authenticated delete" ON public.tree_group_members FOR DELETE USING (auth.role() = 'authenticated' OR auth.role() = 'service_role');


-- 3. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_tree_group_members_group_id ON public.tree_group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_tree_group_members_tree_id ON public.tree_group_members(tree_id);

-- Finish
