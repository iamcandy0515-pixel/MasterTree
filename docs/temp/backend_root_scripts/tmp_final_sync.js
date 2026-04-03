
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function finalSync() {
  const targetEmail = 'iamcandy0515@gmail.com';
  const targetPhone = '01011223344';

  console.log('--- Final Sync Check ---');

  // Check DB
  const { data: dbUser } = await supabase.from('users').select('*').eq('email', targetEmail).maybeSingle();
  console.log('Current DB State:', JSON.stringify(dbUser, null, 2));

  // Check Auth
  const { data: { users } } = await supabase.auth.admin.listUsers();
  const authUser = users.find(u => u.email === targetEmail || u.email === 'phjin9@gmail.com');
  console.log('Current Auth State:', authUser ? { id: authUser.id, email: authUser.email } : 'Not Found');
}

finalSync();
