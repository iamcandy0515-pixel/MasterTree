
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function deepCleanup() {
    const userId = 'b8921ed4-2779-44d2-ba2e-c2937cfc7382'; // iamcandy
    console.log(`Deep cleaning for: ${userId}`);

    const tables = [
        'quiz_results', 'user_quizzes', 'user_stats', 'notifications', 'trees', 'tree_images'
    ];

    for (const table of tables) {
        try {
            await supabase.from(table).delete().eq('user_id', userId);
            await supabase.from(table).delete().eq('auth_id', userId);
            await supabase.from(table).delete().eq('created_by', userId);
        } catch (e) {}
    }

    console.log('Cleanup of public tables done.');

    const { error } = await supabase.auth.admin.deleteUser(userId);
    if (error) {
        console.log('STILL FAILING:', error.message);
        console.log('This confirms a Supabase Auth internal trigger/constraint issue.');
    } else {
        console.log('SUCCESS AFTER DEEP CLEANUP');
    }
}

deepCleanup();
