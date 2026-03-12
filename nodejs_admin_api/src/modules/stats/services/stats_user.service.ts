import { supabase } from "../../../config/supabaseClient";

export class StatsUserService {
    async getUserPerformanceStats(userId: string) {
        // 1. Fetch total published questions and tree count
        const { data: questions } = await supabase
            .from("quiz_questions")
            .select("id, exam_id");

        const { count: treeCount } = await supabase
            .from("trees")
            .select("*", { count: "exact", head: true });

        const totalExamIds = (questions || [])
            .filter((q) => q.exam_id !== null)
            .map((q) => q.id);

        // 2. Fetch user's attempts
        const { data: attempts } = await supabase
            .from("quiz_attempts")
            .select("question_id, tree_id, is_correct")
            .eq("user_id", userId);

        // 3. Process General Quizzes (Tree Quizzes & non-exam questions)
        const solvedGeneralSet = new Set();
        let generalCorrect = 0;
        let generalWrong = 0;

        // 4. Process Past Exams (exam_id is not null)
        const solvedExamSet = new Set();
        let examCorrect = 0;
        let examWrong = 0;

        const examQuestionIds = new Set(totalExamIds);

        attempts?.forEach((att) => {
            if (att.question_id && examQuestionIds.has(att.question_id)) {
                solvedExamSet.add(att.question_id);
                if (att.is_correct) examCorrect++;
                else examWrong++;
            } else {
                // Treat as General Quiz (Tree Quiz)
                const id = att.tree_id ? `t_${att.tree_id}` : att.question_id ? `q_${att.question_id}` : null;
                if (id) {
                    solvedGeneralSet.add(id);
                    if (att.is_correct) generalCorrect++;
                    else generalWrong++;
                }
            }
        });

        // 5. Fetch user info
        let userInfo = null;
        try {
            const { data } = await supabase.auth.admin.getUserById(userId);
            if (data?.user) {
                userInfo = {
                    name: data.user.user_metadata?.name || data.user.email?.split("@")[0],
                    email: data.user.email,
                    lastSignIn: data.user.last_sign_in_at,
                };
            }
        } catch (e) {}

        return {
            user: userInfo,
            quiz: {
                totalCount: treeCount || 0,
                solvedCount: solvedGeneralSet.size,
                correctCount: generalCorrect,
                wrongCount: generalWrong,
            },
            pastExam: {
                totalCount: totalExamIds.length,
                solvedCount: solvedExamSet.size,
                correctCount: examCorrect,
                wrongCount: examWrong,
            },
        };
    }
}

export const statsUserService = new StatsUserService();
