
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function checkHong() {
    const authId = '5e2586a5-33ee-40eb-bd6b-616c78802335';
    console.log('--- Checking HongGildong (Auth ID: 5e2586a5...) ---');

    const { data: user, error } = await supabase.auth.admin.getUserById(authId);
    if (error) console.log('Auth Get Error:', error.message);
    else console.log('Auth Email:', user.user.email);

    const { data: dbUser } = await supabase.from('users').select('*').eq('auth_id', authId).maybeSingle();
    console.log('DB User:', dbUser ? { id: dbUser.id, name: dbUser.name, email: dbUser.email } : 'NOT FOUND');
}

checkHong();
