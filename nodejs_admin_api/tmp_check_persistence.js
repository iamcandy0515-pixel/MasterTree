
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function checkUserPersistence() {
    const email = 'iamcandy0515@gmail.com';
    const id = 'b8921ed4-2779-44d2-ba2e-c2937cfc7382';
    
    console.log(`--- Checking persistence for ${email} ---`);

    // 1. Check Auth
    const { data: { users }, error: authError } = await supabase.auth.admin.listUsers();
    const userInAuth = users.find(u => u.email === email || u.id === id);
    console.log('User in Auth:', userInAuth ? { id: userInAuth.id, email: userInAuth.email } : 'NOT FOUND');

    // 2. Check public.users
    const { data: userInDb } = await supabase.from('users').select('*').or(`email.eq.${email},id.eq.${id},auth_id.eq.${id}`).maybeSingle();
    console.log('User in DB:', userInDb ? userInDb : 'NOT FOUND');

    if (userInAuth || userInDb) {
        console.log('\nUser is STILL ALIVE. Attempting direct deletion in THIS script...');
        if (userInAuth) {
            const { error: delAuth } = await supabase.auth.admin.deleteUser(userInAuth.id);
            console.log('Auth Delete Result:', delAuth ? delAuth.message : 'SUCCESS');
        }
        if (userInDb) {
            const { error: delDb } = await supabase.from('users').delete().eq('id', userInDb.id);
            console.log('DB Delete Result:', delDb ? delDb.message : 'SUCCESS');
        }
    } else {
        console.log('\nUser is NOT FOUND in Supabase. If UI shows it, it might be a refresh issue.');
    }
}

checkUserPersistence();
