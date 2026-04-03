
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

async function updateMasterAdmin() {
  const currentEmail = 'phjin9@gmail.com';
  const newEmail = 'iamcandy0515@gmail.com';
  const newPhone = '01011223344';

  console.log(`--- Updating Master Admin (${currentEmail}) ---`);

  // 1. Find Auth User ID and check for 01011223344 existence
  const { data: { users }, error: listError } = await supabase.auth.admin.listUsers();
  if (listError) {
    console.error('Error listing users:', listError);
    return;
  }

  const authUser = users.find(u => u.email === currentEmail);
  const existingPhoneUser = users.find(u => u.phone === newPhone || u.email.includes(newPhone)); 

  console.log('Target Auth User:', authUser ? authUser.id : 'Not Found');

  // Check public.users for the same phone
  const { data: pUserCheck } = await supabase.from('users').select('name, email').eq('phone', newPhone).maybeSingle();
  if (pUserCheck) {
    console.log(`Warning: Phone ${newPhone} is already being used by: ${pUserCheck.name} (${pUserCheck.email})`);
    console.log('Deleting conflict user to allow Master Admin update...');
    await supabase.from('users').delete().eq('phone', newPhone);
  }

  if (authUser) {
    // 2. Update Auth User
    const { data: updateAuth, error: authUpdateError } = await supabase.auth.admin.updateUserById(
      authUser.id,
      { 
        email: newEmail,
        user_metadata: { ...authUser.user_metadata, user_email: newEmail, name: 'Master Admin' }
      }
    );

    if (authUpdateError) {
      console.error('Error updating Auth user:', authUpdateError);
    } else {
      console.log('Auth user updated successfully.');
    }
  }

  // 3. Update Public.Users table
  const { data: updatePublic, error: publicUpdateError } = await supabase
    .from('users')
    .update({ 
      email: newEmail, 
      phone: newPhone 
    })
    .eq('email', currentEmail);

  if (publicUpdateError) {
    console.error('Error updating public.users table:', publicUpdateError);
  } else {
    console.log('Public users table updated successfully.');
  }
}

updateMasterAdmin();
