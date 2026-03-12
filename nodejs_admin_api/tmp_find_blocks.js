
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function findBlockingDependencies() {
    const userId = 'b8921ed4-2779-44d2-ba2e-c2937cfc7382'; // Auth ID for iamcandy
    const dbUserId = 'b7d0bb50-2590-4d38-bf0d-443fa3a1afdd'; // Master Admin DB ID

    console.log(`--- Checking dependencies for User IDs ---`);

    // Standard tables in this project
    const tables = [
        'trees', 
        'tree_images', 
        'quiz_questions', 
        'quiz_results', 
        'user_quizzes', 
        'user_stats', 
        'notifications',
        'tree_groups'
    ];

    for (const table of tables) {
        const { data, error } = await supabase
            .from(table)
            .select('id', { count: 'exact' })
            .or(`user_id.eq.${userId},auth_id.eq.${userId},created_by.eq.${userId},user_id.eq.${dbUserId},auth_id.eq.${dbUserId}`);
        
        if (error) {
            // console.log(`Table ${table} check failed: ${error.message}`);
        } else if (data && data.length > 0) {
            console.log(`[ALERT] Table '${table}' has ${data.length} records linked to these IDs.`);
        }
    }

    // Try deleting Master Admin record specifically to see the error
    console.log('\n--- Tentative delete of Master Admin DB record ---');
    const { error: delErr } = await supabase.from('users').delete().eq('id', dbUserId);
    if (delErr) {
        console.log('BLOCKING ERROR:', delErr.message);
        console.log('DETAIL:', delErr.details);
        console.log('HINT:', delErr.hint);
    } else {
        console.log('No blocking error in users table (but maybe transaction was partial)');
    }
}

findBlockingDependencies();
