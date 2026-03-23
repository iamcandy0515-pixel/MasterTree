import { supabase } from "../../../config/supabaseClient";

export class QuizStatService {
    /**
     * Get aggregated lightweight stats for User Dashboard
     */
    async getAggregatedStats(userId: string) {
        const { data: attempts, error: attErr } = await supabase
            .from("quiz_attempts")
            .select("is_correct, category_id, created_at")
            .eq("user_id", userId)
            .order("created_at", { ascending: false })
            .limit(500);

        if (attErr) throw new Error(`Failed fetching stats: ${attErr.message}`);

        const totalAttempts = attempts?.length || 0;
        const correctAttempts = attempts?.filter((a) => a.is_correct).length || 0;
        const overallAccuracy = totalAttempts === 0 ? 0 : Math.round((correctAttempts / totalAttempts) * 100);

        const categoryStats: Record<number, { fail: number; total: number }> = {};
        for (const a of attempts || []) {
            if (!a.category_id) continue;
            if (!categoryStats[a.category_id]) categoryStats[a.category_id] = { fail: 0, total: 0 };
            categoryStats[a.category_id].total += 1;
            if (!a.is_correct) categoryStats[a.category_id].fail += 1;
        }

        const weaknessRanking = Object.entries(categoryStats)
            .map(([cid, stat]) => ({
                category_id: parseInt(cid),
                failRate: Math.round((stat.fail / stat.total) * 100),
                total: stat.total,
            }))
            .filter((w) => w.total >= 3)
            .sort((a, b) => b.failRate - a.failRate)
            .slice(0, 3);

        const { data: sessions } = await supabase
            .from("quiz_sessions")
            .select("started_at, correct_count, total_questions")
            .eq("user_id", userId)
            .not("finished_at", "is", null)
            .order("started_at", { ascending: false })
            .limit(7);

        return {
            overallAccuracy,
            totalAttempts,
            weaknessRanking,
            recentTrends: (sessions || [])
                .map((s: any) => ({
                    started_at: s.started_at,
                    total_score: (s.total_questions && s.total_questions > 0)
                        ? Math.round(((s.correct_count || 0) / s.total_questions) * 100)
                        : 0,
                }))
                .reverse(),
        };
    }
}

export const quizStatService = new QuizStatService();
