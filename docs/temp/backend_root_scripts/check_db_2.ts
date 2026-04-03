import { supabase } from "./src/config/supabaseClient";

async function checkQuestions() {
    const qIds = [78, 82, 76, 36];
    const { data: qs } = await supabase.from("quiz_questions").select("id, exam_id").in("id", qIds);
    console.log("Questions with exam_id check:", qs);
}

checkQuestions();
