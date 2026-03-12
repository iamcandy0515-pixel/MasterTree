
const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../../.env') });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function listAllTables() {
  console.log('--- Listing All Tables in Public Schema ---');
  // Using a trick: query a non-existent table to see error or use a known one
  const tables = ['quiz_questions', 'quiz_attempts', 'quiz_sessions', 'quiz_exams', 'trees', 'categories'];
  for (const table of tables) {
    const { count, error } = await supabase.from(table).select('*', { count: 'exact', head: true });
    if (error) {
      console.log(`Table ${table}: ERROR - ${error.message}`);
    } else {
      console.log(`Table ${table}: OK - Count: ${count}`);
    }
  }
  
  console.log('\n--- Checking Questions with status=published ---');
  const { data: pubQs } = await supabase.from('quiz_questions').select('id, exam_id, status').eq('status', 'published');
  console.table(pubQs);
}

listAllTables();
