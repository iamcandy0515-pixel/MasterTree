require('dotenv').config({ path: './.env' });
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

async function migrateTargetUsers() {
  console.log('Starting Target Users Migration (phjin9@gmail.com)...');
  
  const targetEmail = 'phjin9@gmail.com';
  
  // 1. Identify Target Users in public.users
  // We'll target '홍길동' and 'Master Admin' (admin)
  const { data: users, error: userError } = await supabase
    .from('users')
    .select('id, name, phone, auth_id')
    .or('name.eq.홍길동,name.eq.Master Admin');

  if (userError) {
    console.error('Error fetching users:', userError);
    return;
  }

  for (const user of users) {
    console.log(`Processing User: ${user.name} (${user.phone})`);
    
    // Update public.users email
    const { error: updatePublicError } = await supabase
      .from('users')
      .update({ email: targetEmail })
      .eq('id', user.id);
      
    if (updatePublicError) {
      console.error(`  !! Failed to update public.users for ${user.id}:`, updatePublicError.message);
    } else {
      console.log(`  -> Updated public.users email to ${targetEmail}`);
    }

    // Update or Create Auth User
    if (user.auth_id) {
       try {
         const { error: authUpdateError } = await supabase.auth.admin.updateUserById(
           user.auth_id,
           { email: targetEmail, email_confirm: true }
         );
         if (authUpdateError) {
           console.error(`  !! Failed to update Auth for ${user.auth_id}:`, authUpdateError.message);
         } else {
           console.log(`  -> Updated Auth email for ${user.auth_id} to ${targetEmail}`);
         }
       } catch (ae) {
         console.error(`  !! Exception updating Auth:`, ae.message);
       }
    } else {
      console.log(`  [Note] User ${user.name} has no auth_id yet. Will be handled during next login.`);
    }
  }

  console.log('Target Users Migration completed.');
}

migrateTargetUsers();
