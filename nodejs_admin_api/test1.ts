import "dotenv/config";
import { supabase } from "./src/config/supabaseClient";

async function check() {
    const { data: cData } = await supabase.from("quiz_categories").select("*");
    console.log("Categories:", cData);
    const { data: eData } = await supabase.from("quiz_exams").select("*");
    console.log("Exams:", eData);
    const { data: qData } = await supabase
        .from("quiz_questions")
        .select("id, category_id, exam_id");
    console.log("Questions:", qData);
}

check().then(() => process.exit(0));
