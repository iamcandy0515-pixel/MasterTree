
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function updatePasswords() {
  const newPassword = 'admin1234';
  
  console.log(`--- Syncing All Auth User Passwords to: ${newPassword} ---`);

  // 1. List all users
  const { data: { users }, error: listError } = await supabase.auth.admin.listUsers();
  if (listError) {
    console.error('Error listing users:', listError);
    return;
  }

  console.log(`Found ${users.length} users in Auth.`);

  for (const user of users) {
    console.log(`Updating password for: ${user.email} (${user.id})`);
    const { error: updateError } = await supabase.auth.admin.updateUserById(user.id, {
      password: newPassword
    });

    if (updateError) {
      console.error(`Failed to update ${user.email}:`, updateError.message);
    } else {
      console.log(`Successfully updated ${user.email}`);
    }
  }

  console.log('\n--- Sync Complete ---');
}

updatePasswords();
