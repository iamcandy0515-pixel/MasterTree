require('dotenv').config({ path: './.env' });
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

async function forceSyncAuth() {
  console.log('Force Syncing Auth accounts to phjin9@gmail.com...');
  
  const targetEmail = 'phjin9@gmail.com';
  const systemFixedPassword = 'mastertree_permanent_2026';

  // 1. Check if an Auth user with phjin9@gmail.com already exists
  const { data: { users: allAuthUsers } } = await supabase.auth.admin.listUsers();
  const existingAuthUser = allAuthUsers.find(u => u.email === targetEmail);

  let finalAuthId;

  if (existingAuthUser) {
    console.log(`Found existing Auth user for ${targetEmail}: ${existingAuthUser.id}`);
    finalAuthId = existingAuthUser.id;
  } else {
    // 2. Create it if not exists
    console.log(`Creating new Auth user for ${targetEmail}...`);
    const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
      email: targetEmail,
      password: systemFixedPassword,
      email_confirm: true,
      user_metadata: { name: 'Master Admin' }
    });
    
    if (createError) {
      console.error('Failed to create Auth user:', createError.message);
      return;
    }
    finalAuthId = newUser.user.id;
    console.log(`Created Auth user: ${finalAuthId}`);
  }

  // 3. Link both '홍길동' and 'Master Admin' in public.users to this same Auth ID
  // (Note: In Supabase Auth, multiple public users can technically share an auth_id, 
  // but it's cleaner to have them separate or unified. Here we'll link them both for test convenience)
  const { error: linkError } = await supabase
    .from('users')
    .update({ auth_id: finalAuthId, email: targetEmail })
    .or('name.eq.홍길동,name.eq.Master Admin');

  if (linkError) {
    console.error('Failed to link public users:', linkError.message);
  } else {
    console.log(`Successfully linked 홍길동 and Master Admin to ${targetEmail}`);
  }
  
  // 4. Cleanup old confusing users if they exist
  const oldEmails = ['hong@mastertree.com', 'admin@mastertree.com', 'test@example.com'];
  for (const email of oldEmails) {
    const oldU = allAuthUsers.find(u => u.email === email);
    if (oldU) {
       console.log(`Deleting old test user: ${email} (${oldU.id})`);
       await supabase.auth.admin.deleteUser(oldU.id);
    }
  }

  console.log('Force Sync completed.');
}

forceSyncAuth();
