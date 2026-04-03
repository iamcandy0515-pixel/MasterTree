
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function forceDelete() {
    const userId = 'b8921ed4-2779-44d2-ba2e-c2937cfc7382'; // iamcandy0515
    console.log(`Force deleting user: ${userId}`);

    // 1. Delete from Auth
    const { error: authError } = await supabase.auth.admin.deleteUser(userId);
    if (authError) {
        console.error('Auth Delete Error:', authError);
    } else {
        console.log('Auth Delete Success');
    }

    // 2. Delete from DB
    const { error: dbError } = await supabase.from('users').delete().or(`id.eq.${userId},auth_id.eq.${userId}`);
    if (dbError) {
        console.error('DB Delete Error:', dbError);
    } else {
        console.log('DB Delete Success');
    }
}

forceDelete();
