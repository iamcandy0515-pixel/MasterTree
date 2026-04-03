import { supabase } from "./src/config/supabaseClient";
import * as dotenv from "dotenv";

dotenv.config();

async function checkQuizCount() {
    try {
        const { count, error } = await supabase
            .from("quiz_questions")
            .select("*", { count: "exact", head: true });

        if (error) throw error;
        console.log(`\n[DB Status] Total quiz questions: ${count}\n`);
    } catch (e) {
        console.error("Error checking count:", e);
    }
}

checkQuizCount();
