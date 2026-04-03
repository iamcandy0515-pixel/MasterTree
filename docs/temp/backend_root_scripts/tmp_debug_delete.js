
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function checkConstraints() {
    const userId = 'b8921ed4-2779-44d2-ba2e-c2937cfc7382';
    console.log(`Checking for data linked to user: ${userId}`);

    const tables = ['quiz_results', 'user_quizzes', 'user_stats', 'notifications'];
    
    for (const table of tables) {
        try {
            const { data, error } = await supabase.from(table).select('count').eq('user_id', userId);
            if (!error) {
                console.log(`Table ${table}: Found items?`, data);
            } else {
                if (error.code !== 'PGRST116' && error.code !== '42P01') {
                   // console.log(`Table ${table} error:`, error.message);
                }
            }
        } catch (e) {}
    }

    // Try deleting and capturing the exact raw error
    console.log('\nTrying direct delete to see RAW error...');
    const { error: publicError } = await supabase
        .from('users')
        .delete()
        .eq('id', userId);
    
    if (publicError) {
        console.log('RAW DB Error:', JSON.stringify(publicError, null, 2));
    } else {
        console.log('Delete successful in this script?');
    }
}

checkConstraints();
