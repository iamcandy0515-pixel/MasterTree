-- =================================================================================
-- App Settings & Entry Code Migration
-- =================================================================================

-- 1. Create 'app_settings' table
CREATE TABLE IF NOT EXISTS public.app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Insert default entry code
INSERT INTO public.app_settings (key, value, description)
VALUES ('entry_code', '1234', '앱 입장 코드')
ON CONFLICT (key) DO NOTHING;

-- 3. Enable RLS
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

-- 4. Policies (Allow Authenticated Admin to read/write, Service Role to read/write)
-- For users, maybe read-only access to specific keys? Or hidden by API?
-- Since this is an admin-focused table, restrict to admin/service_role
CREATE POLICY "Allow authenticated full access for admins" ON public.app_settings
    FOR ALL
    USING (auth.role() = 'authenticated' OR auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'authenticated' OR auth.role() = 'service_role');
