
const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../../.env') });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkPastExamStats() {
  console.log('--- DB Statistics Analysis ---');
  
  // 1. Get all exam question IDs
  const { data: examQs } = await supabase
    .from('quiz_questions')
    .select('id')
    .not('exam_id', 'is', null);
    
  const examQIdSet = new Set(examQs?.map(q => q.id) || []);
  console.log(`Verified Exam Questions count in DB: ${examQIdSet.size}`);

  // 2. Get all attempts
  const { data: allAttempts, error: attError } = await supabase
    .from('quiz_attempts')
    .select('user_id, question_id, is_correct');

  if (attError) {
    console.error('Error fetching attempts:', attError.message);
    return;
  }

  if (!allAttempts || allAttempts.length === 0) {
    console.log('❌ quiz_attempts 테이블에 데이터가 전혀 없습니다. (현재 0건)');
    return;
  }

  console.log(`Total attempts found: ${allAttempts.length}`);

  // 3. Group by user and filter by exam questions
  const userStats = {};

  allAttempts.forEach(att => {
    const isExam = examQIdSet.has(att.question_id);
    if (!isExam) return; // Skip non-exam questions

    const uid = att.user_id;
    if (!userStats[uid]) {
      userStats[uid] = {
        userId: uid,
        pastExamAttemptCount: 0,
        correctCount: 0,
        wrongCount: 0
      };
    }
    
    userStats[uid].pastExamAttemptCount++;
    if (att.is_correct) userStats[uid].correctCount++;
    else userStats[uid].wrongCount++;
  });

  const statsList = Object.values(userStats);
  if (statsList.length === 0) {
    console.log('❌ quiz_attempts 테이블에 데이터는 있으나, 기출문제(exam_id != null)인 데이터는 없습니다.');
  } else {
    console.log('--- User-wise Past Exam Stats ---');
    console.table(statsList);
  }
}

checkPastExamStats();
