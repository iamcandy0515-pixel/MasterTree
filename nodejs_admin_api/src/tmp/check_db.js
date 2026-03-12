
const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../../.env') });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function check() {
  console.log('--- Counts ---');
  const { count: qCount } = await supabase.from('quiz_questions').select('*', { count: 'exact', head: true });
  const { count: aCount } = await supabase.from('quiz_attempts').select('*', { count: 'exact', head: true });
  const { count: sCount } = await supabase.from('quiz_sessions').select('*', { count: 'exact', head: true });
  
  console.log('Total Questions:', qCount);
  console.log('Total Attempts:', aCount);
  console.log('Total Sessions:', sCount);

  console.log('\n--- Recent Attempts (Raw) ---');
  const { data: attempts } = await supabase.from('quiz_attempts').select('*').order('created_at', { ascending: false }).limit(5);
  console.table(attempts);

  if (attempts && attempts.length > 0) {
      console.log('Attempt[0] question_id:', attempts[0].question_id, typeof attempts[0].question_id);
  }
}

check();
