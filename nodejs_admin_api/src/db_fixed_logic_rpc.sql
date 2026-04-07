-- 1. 수목 분류 통계 RPC (수정)
CREATE OR REPLACE FUNCTION get_user_tree_category_stats(p_user_id UUID)
RETURNS TABLE (
    category_name TEXT, 
    total_count BIGINT,
    mastered_count BIGINT,
    in_progress_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        data.category_name,
        data.total_count,
        data.mastered_count,
        (data.total_count - data.mastered_count)::BIGINT as in_progress_count -- ← Fixed logic
    FROM (
        SELECT 
            m.display_name as category_name,
            COUNT(t.id)::BIGINT as total_count,
            COUNT(uqs.id) FILTER (WHERE uqs.is_last_correct = true)::BIGINT as mastered_count
        FROM trees t
        JOIN tree_category_mapping m ON t.category = m.original_name
        LEFT JOIN user_quiz_summary uqs ON t.id = uqs.tree_id AND uqs.user_id = p_user_id
        GROUP BY m.display_name
    ) data;
END;
$$ LANGUAGE plpgsql;

-- 2. 기출 회차 통계 RPC (수정)
CREATE OR REPLACE FUNCTION get_user_exam_session_stats(p_user_id UUID)
RETURNS TABLE (
    exam_id BIGINT,
    subject_name TEXT,
    total_count BIGINT,
    mastered_count BIGINT,
    in_progress_count BIGINT,
    accuracy_rate NUMERIC(5,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        data.exam_id,
        data.subject_name,
        data.total_count,
        data.mastered_count,
        (data.total_count - data.mastered_count)::BIGINT as in_progress_count, -- ← Fixed logic
        CASE WHEN data.total_count > 0 THEN (data.mastered_count::FLOAT / data.total_count) * 100 ELSE 0 END::NUMERIC(5,2) as accuracy_rate
    FROM (
        SELECT 
            e.id as exam_id,
            e.title as subject_name,
            COUNT(q.id)::BIGINT as total_count,
            COUNT(uqs.id) FILTER (WHERE uqs.is_last_correct = true)::BIGINT as mastered_count
        FROM quiz_exams e
        JOIN quiz_questions q ON q.exam_id = e.id
        LEFT JOIN user_quiz_summary uqs ON q.id = uqs.question_id AND uqs.user_id = p_user_id
        GROUP BY e.id, e.title
    ) data;
END;
$$ LANGUAGE plpgsql;
