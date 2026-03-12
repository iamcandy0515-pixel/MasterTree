
const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../../.env') });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkColumns() {
  // Let's try to insert a fake attempt and see what happens (rollback or just look at error)
  const { data, error } = await supabase
    .from('quiz_attempts')
    .insert([{ 
        user_id: '00000000-0000-0000-0000-000000000000', 
        question_id: 1, 
        is_correct: true,
        user_answer: 'mock'
    }])
    .select();
    
  if (error) {
      console.log('Insert Error (expected if cols wrong):', error.message);
  } else {
      console.log('Insert Success! Columns seem correct.');
      // Cleanup
      await supabase.from('quiz_attempts').delete().eq('user_id', '00000000-0000-0000-0000-000000000000');
  }
}
checkColumns();
