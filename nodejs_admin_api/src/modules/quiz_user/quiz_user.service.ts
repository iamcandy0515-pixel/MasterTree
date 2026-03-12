import { supabase } from "../../config/supabaseClient";

export class QuizUserService {
    /**
     * Start a new quiz session and fetch randomized or weakness-targeted questions.
     */
    async generateSession(
        userId: string,
        mode: string = "normal", // changed from session_type/sessionType
        limit: number = 10,
    ) {
        // 1. Create a session
        const { data: session, error: sessionErr } = await supabase
            .from("quiz_sessions")
            .insert({
                user_id: userId,
                mode: mode, // Column is 'mode'
            })
            .select("*")
            .single();

        if (sessionErr || !session) {
            throw new Error(`Failed to create session: ${sessionErr?.message}`);
        }

        let questionsQuery = supabase
            .from("quiz_questions")
            .select("*")
            .eq("status", "published");

        if (mode === "pastExam") {
            questionsQuery = questionsQuery.not("exam_id", "is", null);
        } else if (mode === "normal") {
            questionsQuery = questionsQuery.is("exam_id", null);
        }

        const { data: rawQuestions, error: qsError } =
            await questionsQuery.limit(limit * 3);

        if (qsError || !rawQuestions) {
            throw new Error(`Failed to fetch questions: ${qsError?.message}`);
        }

        const shuffled = rawQuestions
            .sort(() => 0.5 - Math.random())
            .slice(0, limit);

        return {
            session_id: session.id,
            started_at: session.started_at,
            questions: shuffled.map((q: any) => ({
                id: q.id,
                category_id: q.category_id,
                content_blocks: q.content_blocks,
                options: q.options,
                correct_option_index: q.correct_option_index,
                explanation_blocks: q.explanation_blocks,
            })),
        };
    }

    /**
     * Submit user answers and update session stats.
     */
    async submitAttempts(userId: string, sessionId: number, attempts: any[]) {
        const attemptRows = attempts.map((a) => ({
            session_id: sessionId,
            user_id: userId,
            question_id: a.question_id,
            category_id: a.category_id,
            is_correct: a.is_correct,
            user_answer: a.user_answer,
            time_taken_ms: a.time_taken_ms,
        }));

        const { error: insErr } = await supabase
            .from("quiz_attempts")
            .insert(attemptRows);
        if (insErr)
            throw new Error(`Insert attempts failed: ${insErr.message}`);

        const correctCount = attemptRows.filter((a) => a.is_correct).length;
        const totalQuestions = attemptRows.length;

        const { error: updErr } = await supabase
            .from("quiz_sessions")
            .update({
                finished_at: new Date().toISOString(), // Column is 'finished_at'
                correct_count: correctCount, // Column is 'correct_count'
                total_questions: totalQuestions, // Column is 'total_questions'
            })
            .eq("id", sessionId)
            .eq("user_id", userId);

        if (updErr) throw new Error(`Update session failed: ${updErr.message}`);

        return { correctCount, total: totalQuestions };
    }

    /**
     * Save a batch of attempts (Sync)
     * Corrected to use 'mode' and 'finished_at'
     */
    async saveBatchAttempts(userId: string, attempts: any[]) {
        if (!attempts || attempts.length === 0) return { success: true };

        // 1. Validate Question IDs (Filter out non-existent questions to prevent FK violation)
        const questionIds = [...new Set(attempts.map((a) => a.question_id))];
        const { data: validQs, error: qsErr } = await supabase
            .from("quiz_questions")
            .select("id")
            .in("id", questionIds);

        if (qsErr) throw new Error(`Validation failed: ${qsErr.message}`);

        const validIdSet = new Set(validQs?.map((q) => q.id) || []);
        const filteredAttempts = attempts.filter((a) =>
            validIdSet.has(a.question_id),
        );

        if (filteredAttempts.length === 0) {
            console.log(
                `[saveBatchAttempts] All ${attempts.length} attempts were for non-existent questions. Skipping.`,
            );
            return { success: true, count: 0, filtered: attempts.length };
        }

        if (filteredAttempts.length < attempts.length) {
            console.warn(
                `[saveBatchAttempts] Filtered out ${attempts.length - filteredAttempts.length} invalid questions.`,
            );
        }

        // 2. Get or Create Session
        const sessionId = await this.getOrCreateSession(userId);

        // 3. Prepare attempt rows
        const attemptRows = filteredAttempts.map((a) => ({
            session_id: sessionId,
            user_id: userId,
            question_id: a.question_id,
            category_id: a.category_id,
            is_correct: a.is_correct,
            user_answer: a.user_answer || "",
            time_taken_ms: a.time_taken_ms || 0,
            created_at: a.created_at || new Date().toISOString(),
        }));

        // 4. Batch insert
        const { error: insErr } = await supabase
            .from("quiz_attempts")
            .insert(attemptRows);

        if (insErr) {
            console.error("[saveBatchAttempts] Insert Error:", insErr);
            throw new Error(`Batch insert failed: ${insErr.message}`);
        }

        // 5. Update session counters
        const correctCount = attemptRows.filter((a) => a.is_correct).length;
        const { data: currentSession } = await supabase
            .from("quiz_sessions")
            .select("correct_count, total_questions")
            .eq("id", sessionId)
            .single();

        await supabase
            .from("quiz_sessions")
            .update({
                correct_count:
                    (currentSession?.correct_count || 0) + correctCount,
                total_questions:
                    (currentSession?.total_questions || 0) + attemptRows.length,
                finished_at: new Date().toISOString(),
            })
            .eq("id", sessionId);

        return {
            success: true,
            count: attemptRows.length,
            filtered: attempts.length - filteredAttempts.length,
        };
    }

    /**
     * Helper to find or create a daily 'normal' session for a user.
     */
    private async getOrCreateSession(userId: string): Promise<number> {
        if (!userId) {
            throw new Error("User ID is missing for session creation.");
        }

        const today = new Date().toISOString().split("T")[0];

        // Find existing 'normal' session for today
        const { data: existingSession } = await supabase
            .from("quiz_sessions")
            .select("id")
            .eq("user_id", userId)
            .eq("mode", "normal") // Use 'mode'
            .gte("started_at", today)
            .limit(1)
            .maybeSingle();

        if (existingSession && existingSession.id) {
            return existingSession.id;
        }

        // Create new one if none found
        const { data: newSession, error: createErr } = await supabase
            .from("quiz_sessions")
            .insert({
                user_id: userId,
                mode: "normal",
            })
            .select("id")
            .single();

        if (createErr || !newSession || !newSession.id) {
            throw new Error(
                `Failed to create auto-session: ${createErr?.message}`,
            );
        }

        return newSession.id;
    }

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
        const correctAttempts =
            attempts?.filter((a) => a.is_correct).length || 0;
        const overallAccuracy =
            totalAttempts === 0
                ? 0
                : Math.round((correctAttempts / totalAttempts) * 100);

        const categoryStats: Record<number, { fail: number; total: number }> =
            {};
        for (const a of attempts || []) {
            if (!a.category_id) continue;
            if (!categoryStats[a.category_id])
                categoryStats[a.category_id] = { fail: 0, total: 0 };
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
            .not("finished_at", "is", null) // Column is 'finished_at'
            .order("started_at", { ascending: false })
            .limit(7);

        return {
            overallAccuracy,
            totalAttempts,
            weaknessRanking,
            recentTrends: (sessions || [])
                .map((s) => ({
                    started_at: s.started_at,
                    total_score:
                        s.total_questions > 0
                            ? Math.round(
                                  (s.correct_count / s.total_questions) * 100,
                              )
                            : 0,
                }))
                .reverse(),
        };
    }
}

export const quizUserService = new QuizUserService();
