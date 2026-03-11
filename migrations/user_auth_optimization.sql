-- [사용자 로그인 및 인증 시스템 고도화] DB 최적화 스크립트
-- 1. 빠른 유저 조회를 위한 복합 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_users_name_phone ON users (name, phone);

-- 2. 활동 유저 식별을 위한 Auth ID 컬럼 확인 (이미 존재할 가능성이 높으나 보장용)
-- Supabase Auth ID(UUID)를 저장할 수 있도록 컬럼 타입 확인 및 생성
-- DO $$ 
-- BEGIN 
--     IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='auth_id') THEN
--         ALTER TABLE users ADD COLUMN auth_id UUID;
--     END IF;
-- END $$;

-- 3. 인덱스 성능 최적화 (강제 분석)
ANALYZE users;
