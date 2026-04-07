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
        data.in_progress_count,
        CASE WHEN data.total_count > 0 THEN (data.mastered_count::FLOAT / data.total_count) * 100 ELSE 0 END::NUMERIC(5,2) as accuracy_rate
    FROM (
        SELECT 
            e.id as exam_id,
            e.title as subject_name,
            COUNT(q.id)::BIGINT as total_count,
            COUNT(uqs.id) FILTER (WHERE uqs.is_last_correct = true)::BIGINT as mastered_count,
            COUNT(uqs.id) FILTER (WHERE uqs.id IS NOT NULL AND uqs.is_last_correct = false)::BIGINT as in_progress_count
        FROM quiz_exams e
        JOIN quiz_questions q ON q.exam_id = e.id  -- ← Fixed: exam_id instead of category_id
        LEFT JOIN user_quiz_summary uqs ON q.id = uqs.question_id AND uqs.user_id = p_user_id
        GROUP BY e.id, e.title
    ) data;
END;
$$ LANGUAGE plpgsql;
