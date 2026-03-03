const { createClient } = require("@supabase/supabase-js");
require("dotenv").config();

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_KEY;
const supabase = createClient(url, key);

async function run() {
    console.log("--- Checking Exam 2020 Round 3 ---");
    const { data: exams, error: examError } = await supabase
        .from("quiz_exams")
        .select("*")
        .eq("year", 2020)
        .eq("round", 3);

    if (examError) {
        console.error("Exam Lookup Error:", examError);
        return;
    }
    console.log("Exams:", JSON.stringify(exams, null, 2));

    if (exams && exams.length > 0) {
        const examId = exams[0].id;
        const { data: quests, error: questError } = await supabase
            .from("quiz_questions")
            .select("id, question_number")
            .eq("exam_id", examId)
            .order("question_number");

        if (questError) {
            console.error("Questions Lookup Error:", questError);
            return;
        }
        console.log(
            "Registered Numbers:",
            quests.map((q) => q.question_number),
        );

        const q12 = quests.find((q) => q.question_number === 12);
        if (q12) {
            console.log("✅ Question 12 EXISTS with ID:", q12.id);
        } else {
            console.log("❌ Question 12 MISSING in DB for this exam.");
        }
    } else {
        console.log("Exam not found.");
    }
}

run();
