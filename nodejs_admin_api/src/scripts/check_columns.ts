import "dotenv/config";
import { supabase } from "../config/supabaseClient";

async function checkColumns() {
    const { data, error } = await supabase
        .from("quiz_questions")
        .select("*")
        .limit(1);

    if (error) {
        console.error("Error:", error);
    } else if (data && data.length > 0) {
        console.log("Columns:", Object.keys(data[0]));
    } else {
        console.log(
            "Empty table, but let's try an insert to see if question_number exists.",
        );
        const { error: insertError } = await supabase
            .from("quiz_questions")
            .insert([
                {
                    content_blocks: [],
                    explanation_blocks: [],
                    question_number: 1,
                    status: "draft",
                },
            ]);
        console.log(
            "Insert response error:",
            insertError ? insertError.message : "Success",
        );
    }
}

checkColumns();
