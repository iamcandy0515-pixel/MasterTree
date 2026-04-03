import { supabase } from "./src/config/supabaseClient";

async function checkQuestions() {
    const { count: total } = await supabase.from("quiz_questions").select("*", { count: "exact", head: true });
    const { count: withExam } = await supabase.from("quiz_questions").select("*", { count: "exact", head: true }).not("exam_id", "is", null);
    const { count: attempts } = await supabase.from("quiz_attempts").select("*", { count: "exact", head: true });
    
    console.log(`Total questions: ${total}`);
    console.log(`Questions with exam_id: ${withExam}`);
    console.log(`Total attempts: ${attempts}`);
    
    const { data: sampleAttempts } = await supabase.from("quiz_attempts").select("question_id").limit(10);
    console.log("Sample attempt question IDs:", sampleAttempts?.map(a => a.question_id));
}

checkQuestions();
