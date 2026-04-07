require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
);

async function updateDB() {
    console.log('Starting DB Update...');
    const sql = `
        ALTER TABLE quiz_sessions DROP CONSTRAINT IF EXISTS quiz_sessions_mode_check;
        ALTER TABLE quiz_sessions ADD CONSTRAINT quiz_sessions_mode_check 
        CHECK (mode IN ('normal', 'pastExam', 'random', 'weakness'));
    `;
    const { data, error } = await supabase.rpc('exec_sql', { sql_string: sql });
    if (error) {
        console.error('❌ Error:', error.message);
    } else {
        console.log('✅ DB Update Done!');
    }
}

updateDB();
