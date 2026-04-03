
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function checkUser() {
  console.log('--- Checking Public.Users Table ---');
  const { data: publicUsers, error: publicError } = await supabase
    .from('users')
    .select('*')
    .or('name.eq.홍길동,email.eq.phjin9@gmail.com');

  if (publicError) {
    console.error('Error fetching public users:', publicError);
  } else {
    console.log('Public Users found:', JSON.stringify(publicUsers, null, 2));
  }

  console.log('\n--- Checking Supabase Auth Users ---');
  const { data: { users }, error: authError } = await supabase.auth.admin.listUsers();

  if (authError) {
    console.error('Error fetching auth users:', authError);
  } else {
    const targetUser = users.find(u => u.email === 'phjin9@gmail.com');
    if (targetUser) {
      console.log('Auth User found:', JSON.stringify(targetUser, null, 2));
    } else {
      console.log('Auth User with email "phjin9@gmail.com" not found.');
    }
  }
}

checkUser();
