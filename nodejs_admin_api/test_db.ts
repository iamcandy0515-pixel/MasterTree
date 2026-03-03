import { supabase } from "./src/config/supabaseClient";

async function checkQuestion() {
    console.log("--- DB Check Start ---");
    try {
        const { data: exams, error: examError } = await supabase
            .from("quiz_exams")
            .select("*")
            .eq("year", 2020)
            .eq("round", 3);

        if (examError) throw examError;
        console.log("Exams found:", exams);

        if (exams && exams.length > 0) {
            const examId = exams[0].id;
            const { data: quest, error: questError } = await supabase
                .from("quiz_questions")
                .select("id, question_number, content_blocks")
                .eq("exam_id", examId)
                .eq("question_number", 12);

            if (questError) throw questError;
            console.log("Question 12 Result:", quest);
        } else {
            console.log("Exam 2020 Round 3 not found.");
        }
    } catch (err) {
        console.error("Error during DB inquiry:", err);
    }
}

checkQuestion();
