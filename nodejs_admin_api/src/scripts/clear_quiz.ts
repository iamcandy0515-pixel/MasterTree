import "dotenv/config";
import { supabase } from "../config/supabaseClient";

async function clearQuizData() {
    try {
        console.log("Clearing quiz data...");

        // delete all rows where id > 0 (for bigint primary keys)
        const { error: qError, count: qCount } = await supabase
            .from("quiz_questions")
            .delete()
            .gt("id", 0);

        if (qError) {
            console.error("Failed to delete quiz_questions:", qError.message);
        } else {
            console.log("Successfully deleted all quiz_questions");
        }

        const { error: eError } = await supabase
            .from("quiz_exams")
            .delete()
            .gt("id", 0);

        if (eError) {
            console.error("Failed to delete quiz_exams:", eError.message);
        } else {
            console.log("Successfully deleted all quiz_exams");
        }

        const { error: cError } = await supabase
            .from("quiz_categories")
            .delete()
            .gt("id", 0);

        if (cError) {
            console.error("Failed to delete quiz_categories:", cError.message);
        } else {
            console.log("Successfully deleted all quiz_categories");
        }

        console.log("Quiz data cleanup complete.");
    } catch (err) {
        console.error("Error:", err);
    }
}

clearQuizData();
