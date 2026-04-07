-- 📊 사용자별 집계 통계를 위한 RPC 함수 정의

-- 1. 수목 분류별 집계 RPC
CREATE OR REPLACE FUNCTION get_user_tree_category_stats(p_user_id UUID)
RETURNS TABLE (
    display_name TEXT,
    total_count BIGINT,
    mastered_count BIGINT,
    in_progress_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.display_name,
        COUNT(t.id)::BIGINT as total_count,
        COUNT(uqs.id) FILTER (WHERE uqs.is_last_correct = true)::BIGINT as mastered_count,
        COUNT(uqs.id) FILTER (WHERE uqs.id IS NOT NULL AND uqs.is_last_correct = false)::BIGINT as in_progress_count
    FROM trees t
    JOIN tree_category_mapping m ON t.category = m.original_name
    LEFT JOIN user_quiz_summary uqs ON t.id = uqs.tree_id AND uqs.user_id = p_user_id
    GROUP BY m.display_name;
END;
$$ LANGUAGE plpgsql;

-- 2. 기출 회차별 집계 RPC
CREATE OR REPLACE FUNCTION get_user_exam_session_stats(p_user_id UUID)
RETURNS TABLE (
    exam_id BIGINT,
    exam_title TEXT,
    subject_name TEXT,
    total_count BIGINT,
    mastered_count BIGINT,
    in_progress_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    WITH exam_q_counts AS (
        SELECT e.id as id_exam, e.title, COUNT(q.id) as total_q
        FROM quiz_exams e
        JOIN quiz_questions q ON q.category_id = e.id -- Assuming category_id maps to exam
        GROUP BY e.id, e.title
    )
    SELECT 
        e.id as exam_id,
        e.title as exam_title,
        e.title as subject_name,
        COUNT(q.id)::BIGINT as total_count,
        COUNT(uqs.id) FILTER (WHERE uqs.is_last_correct = true)::BIGINT as mastered_count,
        COUNT(uqs.id) FILTER (WHERE uqs.id IS NOT NULL AND uqs.is_last_correct = false)::BIGINT as in_progress_count
    FROM quiz_exams e
    JOIN quiz_questions q ON q.category_id = e.id
    LEFT JOIN user_quiz_summary uqs ON q.id = uqs.question_id AND uqs.user_id = p_user_id
    GROUP BY e.id, e.title;
END;
$$ LANGUAGE plpgsql;
