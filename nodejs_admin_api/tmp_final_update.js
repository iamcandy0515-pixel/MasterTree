
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function finalCleanAndUpdate() {
  const targetId = '1305b646-9975-4502-a550-00839a24ca0d';
  const newEmail = 'iamcandy0515@gmail.com';
  const newPhone = '01011223344';

  console.log('--- Final Force Update ---');

  // 1. Delete ANYONE using the new phone in users table
  console.log('Deleting any user with phone:', newPhone);
  const { data: deleted } = await supabase.from('users').delete().eq('phone', newPhone).select();
  console.log('Deleted from DB:', deleted);

  // 2. Update the Master Admin row in public.users by ID (using the id found in check step)
  // Master Admin DB ID: b7d0bb50-2590-4d38-bf0d-443fa3a1afdd
  console.log('Updating Master Admin record...');
  const { error: dbErr } = await supabase.from('users')
    .update({ email: newEmail, phone: newPhone })
    .eq('id', 'b7d0bb50-2590-4d38-bf0d-443fa3a1afdd');
    
  if (dbErr) console.error('DB Update Error:', dbErr);
  else console.log('DB Update Success');

  // 3. Update Auth
  const { error: authErr } = await supabase.auth.admin.updateUserById(targetId, {
    email: newEmail,
    user_metadata: { name: 'Master Admin', user_email: newEmail }
  });
  
  if (authErr) console.error('Auth Update Error:', authErr);
  else console.log('Auth Update Success');
}

finalCleanAndUpdate();
