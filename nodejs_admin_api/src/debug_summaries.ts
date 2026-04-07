import "./env";
import { supabase } from "./config/supabaseClient";

async function debugSummaries() {
    const userId = "5e2586a5-33ee-40eb-bd6b-616c78802335"; // 홍길동
    console.log(`\n🔍 Debugging summaries for user: ${userId}`);

    // 1. Get raw summaries
    const { data: summaries, error: summaryError } = await supabase
        .from("user_quiz_summary" as any)
        .select("*")
        .eq("user_id", userId);

    if (summaryError) {
        console.error("Error fetching summaries:", summaryError);
        return;
    }

    console.log(`Found ${summaries?.length || 0} summaries.`);

    if (summaries && summaries.length > 0) {
        console.log("\nSample Data (First 3):");
        summaries.slice(0, 3).forEach((s: any, idx: number) => {
            console.log(`[${idx}] question_id: ${s.question_id}, tree_id: ${s.tree_id}, exam_id: ${s.exam_id}, is_last_correct: ${s.is_last_correct}`);
        });

        // Check if there are any exam_id or if it is null
        const withExamId = summaries.filter((s: any) => s.exam_id !== null).length;
        const nullExamId = summaries.filter((s: any) => s.exam_id === null).length;
        console.log(`\nStatistics:`);
        console.log(`- Summaries with exam_id: ${withExamId}`);
        console.log(`- Summaries with NULL exam_id: ${nullExamId}`);

        // Check is_last_correct distribution
        const correct = summaries.filter((s: any) => s.is_last_correct === true).length;
        const wrong = summaries.filter((s: any) => s.is_last_correct === false).length;
        console.log(`- is_last_correct: TRUE (${correct}), FALSE (${wrong})`);
    }

    // 2. Fetch total basis counts as in StatsUserService
    const [{ count: questionCount }, { count: treeCount }] = await Promise.all([
        supabase.from("quiz_questions").select("*", { count: "exact", head: true }),
        supabase.from("trees").select("*", { count: "exact", head: true })
    ]);
    console.log(`\nBasis Counts:`);
    console.log(`- Total Quiz Questions: ${questionCount}`);
    console.log(`- Total Trees: ${treeCount}`);

    const { data: questions } = await supabase.from("quiz_questions").select("id, exam_id");
    const examQuestionIds = new Set((questions || []).filter(q => q.exam_id !== null).map(q => q.id));
    console.log(`- Exam Question IDs (with exam_id): ${examQuestionIds.size}`);
}

debugSummaries();
