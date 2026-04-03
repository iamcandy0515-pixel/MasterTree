
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function trial() {
    const userId = 'b8921ed4-2779-44d2-ba2e-c2937cfc7382';
    console.log('Attempting to disable and then delete...');

    // 1. Disable
    const { error: err1 } = await supabase.auth.admin.updateUserById(userId, { ban_duration: 'none' }); // 'none' to unban, but let's try something else
    // Actually, let's try to update email to a dummy one
    const { error: err2 } = await supabase.auth.admin.updateUserById(userId, { email: 'deleted_' + Date.now() + '@test.com' });
    
    if (err2) console.log('Update before delete failed:', err2.message);
    else console.log('Update email success');

    // 2. Delete
    const { error: err3 } = await supabase.auth.admin.deleteUser(userId);
    if (err3) console.log('Final delete attempt failed:', err3.message);
    else console.log('Final delete success');
}

trial();
