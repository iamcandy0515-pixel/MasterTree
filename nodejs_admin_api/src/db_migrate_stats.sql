-- 🚀 기존 데이터를 신규 집계 테이블(user_tree_category_stats, user_exam_session_stats)로 마이그레이션

-- 1. 수목 분류별 초기 집계 데이터 생성
INSERT INTO user_tree_category_stats (user_id, category_name, total_count, mastered_count, in_progress_count, accuracy_rate, updated_at)
SELECT 
    data.user_id,
    data.display_name,
    data.total_count,
    data.mastered_count,
    data.in_progress_count,
    CASE WHEN data.total_count > 0 THEN (data.mastered_count::FLOAT / data.total_count) * 100 ELSE 0 END as accuracy_rate,
    NOW() as updated_at
FROM (
    SELECT 
        u.auth_id as user_id,
        m.display_name,
        COUNT(t.id)::BIGINT as total_count,
        COUNT(uqs.id) FILTER (WHERE uqs.is_last_correct = true)::BIGINT as mastered_count,
        COUNT(uqs.id) FILTER (WHERE uqs.id IS NOT NULL AND uqs.is_last_correct = false)::BIGINT as in_progress_count
    FROM users u
    CROSS JOIN (SELECT DISTINCT display_name FROM tree_category_mapping) m
    JOIN tree_category_mapping tcm ON tcm.display_name = m.display_name
    JOIN trees t ON t.category = tcm.original_name
    LEFT JOIN user_quiz_summary uqs ON t.id = uqs.tree_id AND uqs.user_id = u.auth_id
    WHERE u.auth_id IS NOT NULL
    GROUP BY u.auth_id, m.display_name
) data
ON CONFLICT (user_id, category_name) 
DO UPDATE SET 
    total_count = EXCLUDED.total_count,
    mastered_count = EXCLUDED.mastered_count,
    in_progress_count = EXCLUDED.in_progress_count,
    accuracy_rate = EXCLUDED.accuracy_rate,
    updated_at = NOW();

-- 2. 기출 회차별 초기 집계 데이터 생성
INSERT INTO user_exam_session_stats (user_id, exam_id, subject_name, total_count, mastered_count, in_progress_count, accuracy_rate, updated_at)
SELECT 
    data.user_id,
    data.exam_id,
    data.subject_name,
    data.total_count,
    data.mastered_count,
    data.in_progress_count,
    CASE WHEN data.total_count > 0 THEN (data.mastered_count::FLOAT / data.total_count) * 100 ELSE 0 END as accuracy_rate,
    NOW() as updated_at
FROM (
    SELECT 
        u.auth_id as user_id,
        e.id as exam_id,
        e.title as subject_name,
        COUNT(q.id)::BIGINT as total_count,
        COUNT(uqs.id) FILTER (WHERE uqs.is_last_correct = true)::BIGINT as mastered_count,
        COUNT(uqs.id) FILTER (WHERE uqs.id IS NOT NULL AND uqs.is_last_correct = false)::BIGINT as in_progress_count
    FROM users u
    CROSS JOIN quiz_exams e
    JOIN quiz_questions q ON q.category_id = e.id
    LEFT JOIN user_quiz_summary uqs ON q.id = uqs.question_id AND uqs.user_id = u.auth_id
    WHERE u.auth_id IS NOT NULL
    GROUP BY u.auth_id, e.id, e.title
) data
ON CONFLICT (user_id, exam_id) 
DO UPDATE SET 
    total_count = EXCLUDED.total_count,
    mastered_count = EXCLUDED.mastered_count,
    in_progress_count = EXCLUDED.in_progress_count,
    accuracy_rate = EXCLUDED.accuracy_rate,
    updated_at = NOW();
