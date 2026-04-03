
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function listAll() {
    console.log('--- ALL PUBLIC.USERS ---');
    const { data: dbUsers } = await supabase.from('users').select('id, name, email, phone, auth_id');
    console.log(JSON.stringify(dbUsers, null, 2));

    console.log('\n--- ALL AUTH USERS ---');
    const { data: { users } } = await supabase.auth.admin.listUsers();
    console.log(users.map(u => ({ id: u.id, email: u.email, phone: u.phone, name: u.user_metadata?.name })));
}

listAll();
