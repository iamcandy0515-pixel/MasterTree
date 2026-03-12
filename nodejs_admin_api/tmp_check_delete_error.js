
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function checkUserTable() {
    const userId = 'b8921ed4-2779-44d2-ba2e-c2937cfc7382';
    console.log(`Checking DB for user: ${userId}`);
    
    // Check if exists in public.users
    const { data: userInDb, error: dbError } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .maybeSingle();
        
    if (dbError) console.error('DB Fetch Error:', dbError);
    else console.log('User in public.users:', userInDb);

    // Check if exists in Auth
    const { data: { users }, error: authError } = await supabase.auth.admin.listUsers();
    const userInAuth = users.find(u => u.id === userId);
    console.log('User in Auth:', userInAuth ? 'Found' : 'Not Found');
    
    // Check for foreign key constraints if any
    const { data: trees, error: treeErr } = await supabase.from('trees').select('id').limit(1);
    console.log('Trees table access check:', treeErr ? 'Error' : 'OK');
}

checkUserTable();
