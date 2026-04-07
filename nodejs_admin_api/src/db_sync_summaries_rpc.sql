CREATE OR REPLACE FUNCTION get_latest_quiz_states()
RETURNS TABLE (
    user_id UUID,
    question_id BIGINT,
    tree_id BIGINT,
    is_last_correct BOOLEAN,
    total_attempts BIGINT,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        q.user_id,
        q.question_id,
        q.tree_id,
        q.is_correct as is_last_correct,
        COUNT(*) OVER (PARTITION BY q.user_id, q.question_id, q.tree_id) as total_attempts,
        q.created_at as updated_at
    FROM (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY user_id, question_id, tree_id ORDER BY created_at DESC) as rn
        FROM quiz_attempts
    ) q
    WHERE q.rn = 1;
END;
$$ LANGUAGE plpgsql;
