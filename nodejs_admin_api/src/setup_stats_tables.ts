import './env';
import { supabase } from './config/supabaseClient';

async function setup() {
    console.log('🚀 Starting Database Infrastructure Setup...');

    // 1. Create mapping table
    console.log('1. Creating tree_category_mapping table...');
    const { error: mapErr } = await supabase.rpc('exec_sql', {
        sql_string: `
            CREATE TABLE IF NOT EXISTS tree_category_mapping (
                id BIGSERIAL PRIMARY KEY,
                original_name TEXT NOT NULL UNIQUE,
                display_name TEXT NOT NULL,
                created_at TIMESTAMPTZ DEFAULT NOW()
            );
        `
    });
    if (mapErr) console.log('Mapping table creation info/error:', mapErr.message);

    // 2. Insert mapping data
    console.log('2. Inserting mapping data...');
    const mappings = [
        { original_name: '침엽수,상록수', display_name: '상록침엽수' },
        { original_name: '침엽수, 낙엽수', display_name: '낙엽침엽수' },
        { original_name: '침엽수,낙엽수', display_name: '낙엽침엽수' },
        { original_name: '활엽수, 상록수', display_name: '상록활엽수' },
        { original_name: '활엽수,상록수', display_name: '상록활엽수' },
        { original_name: '활엽수, 낙엽수', display_name: '낙엽활엽수' },
        { original_name: '활엽수,낙엽수', display_name: '낙엽활엽수' }
    ];

    for (const m of mappings) {
        await supabase.from('tree_category_mapping').upsert(m, { onConflict: 'original_name' });
    }

    // 3. Create user_tree_category_stats
    console.log('3. Creating user_tree_category_stats table...');
    await supabase.rpc('exec_sql', {
        sql_string: `
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
        `
    });

    // 4. Create user_exam_session_stats
    console.log('4. Creating user_exam_session_stats table...');
    await supabase.rpc('exec_sql', {
        sql_string: `
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
        `
    });

    // 5. Create Purge Function
    console.log('5. Creating Purge Function for quiz_attempts...');
    await supabase.rpc('exec_sql', {
        sql_string: `
            CREATE OR REPLACE FUNCTION purge_old_quiz_attempts()
            RETURNS void AS $$
            BEGIN
                DELETE FROM quiz_attempts
                WHERE created_at < NOW() - INTERVAL '100 days';
            END;
            $$ LANGUAGE plpgsql;
        `
    });

    console.log('✅ Step 1: Database Infrastructure Setup Completed.');
}

setup();
