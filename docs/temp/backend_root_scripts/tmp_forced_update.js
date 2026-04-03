
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

async function forcedUpdate() {
  const currentEmail = 'phjin9@gmail.com';
  const newEmail = 'iamcandy0515@gmail.com';
  const newPhone = '01011223344';

  console.log(`--- Forced Updating Master Admin ---`);

  // 1. Find and Delete any user currently using the new phone or new email
  console.log('Cleaning up existing data with new info...');
  await supabase.from('users').delete().eq('phone', newPhone);
  await supabase.from('users').delete().eq('email', newEmail);
  
  const { data: { users } } = await supabase.auth.admin.listUsers();
  const conflictAuth = users.filter(u => u.email === newEmail);
  for (const u of conflictAuth) {
    console.log(`Deleting conflict Auth user: ${u.email}`);
    await supabase.auth.admin.deleteUser(u.id);
  }

  // 2. Find target Master Admin
  const masterAuth = users.find(u => u.email === currentEmail);
  if (masterAuth) {
    console.log(`Updating Auth for Master Admin: ${masterAuth.id}`);
    const { error: authErr } = await supabase.auth.admin.updateUserById(masterAuth.id, {
      email: newEmail,
      user_metadata: { name: 'Master Admin', user_email: newEmail }
    });
    if (authErr) console.error('Auth Update Error:', authErr);
    else console.log('Auth Update Success');
  }

  // 3. Update DB
  const { error: dbErr } = await supabase.from('users')
    .update({ email: newEmail, phone: newPhone })
    .eq('email', currentEmail);
    
  if (dbErr) console.error('DB Update Error:', dbErr);
  else console.log('DB Update Success');
}

forcedUpdate();
