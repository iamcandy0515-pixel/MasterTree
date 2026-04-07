import "./env";
import { supabase } from "./config/supabaseClient";

/**
 * Statistics Rebuilder Script
 * --------------------------
 * Recovers statistics from the 'quiz_attempts' table 
 * and populates the 'user_quiz_summary' table.
 */
async function rebuildStats() {
    console.log("🚀 [Rebuilder] Starting Statistics Recovery...");

    // 1. Fetch ALL quiz attempts
    const { data: attempts, error: aErr } = await supabase
        .from("quiz_attempts")
        .select("*")
        .order("created_at", { ascending: true }); // Process in chronological order

    if (aErr) {
        console.error("🚨 [Rebuilder] Failed to fetch attempts:", aErr.message);
        return;
    }

    if (!attempts || attempts.length === 0) {
        console.log("⚠️ [Rebuilder] No quiz attempts found. Nothing to rebuild.");
        return;
    }

    console.log(`📡 [Rebuilder] Found ${attempts.length} attempts. Processing...`);

    // 2. Aggregate latest results by (User, Question) or (User, Tree)
    const summaryMap = new Map<string, any>();

    for (const a of attempts) {
        // Distinct identifier for each question/tree per user
        let key = "";
        if (a.question_id) {
            key = `u${a.user_id}_q${a.question_id}`;
        } else if (a.tree_id) {
            key = `u${a.user_id}_t${a.tree_id}`;
        } else {
            continue; // Skip if no identifier
        }

        // Later entries (due to chronological order) will overwrite the map value
        summaryMap.set(key, {
            user_id: a.user_id,
            question_id: a.question_id || null,
            tree_id: a.tree_id || null,
            is_last_correct: a.is_correct,
            updated_at: a.created_at,
        });
    }

    const uniqueSummaries = Array.from(summaryMap.values());
    console.log(`✨ [Rebuilder] Aggregated into ${uniqueSummaries.length} unique summary records.`);

    // 3. Batch UPSERT into user_quiz_summary
    // Since we don't know the unique index for tree_id, we process them separately or use base upsert
    const { error: upsertErr } = await supabase
        .from("user_quiz_summary" as any)
        .upsert(uniqueSummaries);

    if (upsertErr) {
        console.error("🚨 [Rebuilder] Failed to upsert summaries:", upsertErr.message);
        console.log("💡 [Rebuilder Tip] Check if (user_id, question_id) index exists without (user_id, tree_id).");
    } else {
        console.log(`✅ [Rebuilder] SUCCESS: Synchronized ${uniqueSummaries.length} records to user_quiz_summary!`);
    }
}

rebuildStats()
    .then(() => console.log("🏁 [Rebuilder] Process finished."))
    .catch((err) => console.error(err));
