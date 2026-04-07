CREATE OR REPLACE FUNCTION get_user_tree_category_stats(p_user_id UUID)
RETURNS TABLE (
    category_name TEXT, -- ← Renamed from display_name
    total_count BIGINT,
    mastered_count BIGINT,
    in_progress_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.display_name as category_name, -- ← Use display_name AS category_name
        COUNT(t.id)::BIGINT as total_count,
        COUNT(uqs.id) FILTER (WHERE uqs.is_last_correct = true)::BIGINT as mastered_count,
        COUNT(uqs.id) FILTER (WHERE uqs.id IS NOT NULL AND uqs.is_last_correct = false)::BIGINT as in_progress_count
    FROM trees t
    JOIN tree_category_mapping m ON t.category = m.original_name
    LEFT JOIN user_quiz_summary uqs ON t.id = uqs.tree_id AND uqs.user_id = p_user_id
    GROUP BY m.display_name;
END;
$$ LANGUAGE plpgsql;
