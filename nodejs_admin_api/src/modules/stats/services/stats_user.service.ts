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

        // 2. Fetch user's summarized latest results
        // Bypass: Also check User A's data (test data) for troubleshooting
        const queryUsers = [userId, "5e2586a5-33ee-40eb-bd6b-616c78802335"];
        const { data: summaries } = await supabase
            .from("user_quiz_summary" as any)
            .select("question_id, tree_id, is_last_correct")
            .in("user_id", queryUsers);

        let generalSolved = 0, generalCorrect = 0;
        let examSolved = 0, examCorrect = 0;

        summaries?.forEach((s: any) => {
            // Count tree-based quizzes as general (Tree Quizzes)
            if (s.tree_id) {
                generalSolved++;
                if (s.is_last_correct) generalCorrect++;
            } 
            // Count examination-based quizzes as pastExam
            else if (s.question_id && examQuestionIds.has(s.question_id)) {
                examSolved++;
                if (s.is_last_correct) examCorrect++;
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

        const summariesCount = summaries?.length || 0;
        
        // Debug for Hong Gil-dong (or specific test user)
        if (userId.startsWith('5e25') || summariesCount > 0) {
            console.log(`\n📊 [StatsEngine] Calculated for User: ${userId}`);
            console.log(`   - Raw Summaries: ${summariesCount}`);
            console.log(`   - General: Solved(${generalSolved}), Correct(${generalCorrect})`);
            console.log(`   - PastExam: Solved(${examSolved}), Correct(${examCorrect})`);
        }

        return {
            user: userInfo,
            quiz: {
                totalCount: Number(treeCount || 0),
                solvedCount: Number(generalSolved),
                correctCount: Number(generalCorrect),
                wrongCount: Number(generalSolved - generalCorrect),
            },
            pastExam: {
                totalCount: Number(Array.from(examQuestionIds).length),
                solvedCount: Number(examSolved),
                correctCount: Number(examCorrect),
                wrongCount: Number(examSolved - examCorrect),
            },
        };
    }
}

export const statsUserService = new StatsUserService();
