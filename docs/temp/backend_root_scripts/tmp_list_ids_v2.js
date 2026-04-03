
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function listAll() {
    let output = '';
    
    output += '--- ALL PUBLIC.USERS ---\n';
    const { data: dbUsers } = await supabase.from('users').select('id, name, email, phone, auth_id');
    output += JSON.stringify(dbUsers, null, 2) + '\n\n';

    output += '--- ALL AUTH USERS ---\n';
    const { data: { users } } = await supabase.auth.admin.listUsers();
    const authList = users.map(u => ({ id: u.id, email: u.email, phone: u.phone, name: u.user_metadata?.name }));
    output += JSON.stringify(authList, null, 2) + '\n';

    fs.writeFileSync('id_list.txt', output, 'utf8');
    console.log('Saved to id_list.txt');
}

listAll();
