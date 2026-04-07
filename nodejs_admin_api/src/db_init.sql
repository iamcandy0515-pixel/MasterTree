-- 🚀 학습 통계 고도화 및 DB 최적화를 위한 기초 테이블 생성 스크립트
-- 이 스크립트를 Supabase SQL Editor에서 실행해주세요.

-- 1. 수목 분류 매칭 테이블
CREATE TABLE IF NOT EXISTS tree_category_mapping (
    id BIGSERIAL PRIMARY KEY,
    original_name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 수목 분류별 집계 통계 테이블
CREATE TABLE IF NOT EXISTS user_tree_category_stats (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    category_name TEXT NOT NULL,
    total_count INTEGER DEFAULT 0,
    mastered_count INTEGER DEFAULT 0,
    in_progress_count INTEGER DEFAULT 0,
    accuracy_rate NUMERIC(5,2) DEFAULT 0.00,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, category_name)
);

-- 3. 기출 회차별 집계 통계 테이블
CREATE TABLE IF NOT EXISTS user_exam_session_stats (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    exam_id BIGINT NOT NULL,
    subject_name TEXT,
    total_count INTEGER DEFAULT 0,
    mastered_count INTEGER DEFAULT 0,
    in_progress_count INTEGER DEFAULT 0,
    accuracy_rate NUMERIC(5,2) DEFAULT 0.00,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, exam_id)
);

-- 4. 오래된 로그 자동 삭제 함수 (로그 로테이션)
CREATE OR REPLACE FUNCTION purge_old_quiz_attempts()
RETURNS void AS $$
BEGIN
    DELETE FROM quiz_attempts
    WHERE created_at < NOW() - INTERVAL '100 days';
END;
$$ LANGUAGE plpgsql;

-- 📝 인덱스 추가 (조회 최적화)
CREATE INDEX IF NOT EXISTS idx_user_tree_cat_user ON user_tree_category_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_user_exam_session_user ON user_exam_session_stats(user_id);
