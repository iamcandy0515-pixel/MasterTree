import "dotenv/config";
import { supabase } from "../config/supabaseClient";

async function checkCount() {
    const { count, error } = await supabase
        .from("quiz_questions")
        .select("*", { count: "exact", head: true });

    if (error) {
        console.error("Error:", error);
    } else {
        console.log(`Current quiz_questions count: ${count}`);
    }
}

checkCount();
