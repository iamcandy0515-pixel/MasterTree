import { supabase } from "../../../config/supabaseClient";

export class StatsUserService {
    async getUserPerformanceStats(userId: string) {
        // 1. Fetch total published counts for basis
        const [{ count: questionCount }, { count: treeCount }] = await Promise.all([
            supabase.from("quiz_questions").select("*", { count: "exact", head: true }),
            supabase.from("trees").select("*", { count: "exact", head: true })
        ]);

        const { data: questions } = await supabase.from("quiz_questions").select("id, exam_id");
        const examQuestionIds = new Set((questions || []).filter(q => q.exam_id !== null).map(q => q.id));

        // 2. Fetch user's summarized latest results (Pre-aggregated by user_id/question_id)
        const { data: summaries } = await supabase
            .from("user_quiz_summary" as any)
            .select("question_id, tree_id, is_last_correct, exam_id")
            .eq("user_id", userId);

        let generalSolved = 0, generalCorrect = 0;
        let examSolved = 0, examCorrect = 0;

        summaries?.forEach((s: any) => {
            const isExam = s.exam_id !== null || (s.question_id && examQuestionIds.has(s.question_id));
            
            if (isExam) {
                examSolved++;
                if (s.is_last_correct) examCorrect++;
            } else {
                generalSolved++;
                if (s.is_last_correct) generalCorrect++;
            }
        });

        // 3. Fetch user info
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
                solvedCount: generalSolved,
                correctCount: generalCorrect,
                wrongCount: generalSolved - generalCorrect,
            },
            pastExam: {
                totalCount: Array.from(examQuestionIds).length,
                solvedCount: examSolved,
                correctCount: examCorrect,
                wrongCount: examSolved - examCorrect,
            },
        };
    }
}

export const statsUserService = new StatsUserService();
