import { supabase } from "../../../config/supabaseClient";

export class QuizSessionService {
    /**
     * Start a new quiz session and fetch randomized questions.
     */
    async generateSession(userId: string, mode: string = "normal", limit: number = 10) {
        const { data: session, error: sessionErr } = await supabase
            .from("quiz_sessions")
            .insert({ user_id: userId, mode: mode })
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

        const { data: rawQuestions, error: qsError } = await questionsQuery.limit(limit * 3);
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
     * Helper to find or create a daily session for a user.
     */
    async getOrCreateSession(userId: string, mode: string = "normal"): Promise<number> {
        if (!userId) throw new Error("User ID is missing for session creation.");
        const today = new Date().toISOString().split("T")[0];

        const { data: existingSession } = await supabase
            .from("quiz_sessions")
            .select("id")
            .eq("user_id", userId)
            .eq("mode", mode)
            .gte("started_at", today)
            .limit(1)
            .maybeSingle();

        if (existingSession && existingSession.id) return existingSession.id;

        const { data: newSession, error: createErr } = await supabase
            .from("quiz_sessions")
            .insert({ user_id: userId, mode: mode })
            .select("id")
            .single();

        if (createErr || !newSession || !newSession.id) {
            throw new Error(`Failed to create auto-session: ${createErr?.message}`);
        }
        return newSession.id;
    }

    async updateSessionStats(userId: string, sessionId: number, correctCount: number, totalQuestions: number) {
        const { error } = await supabase
            .from("quiz_sessions")
            .update({
                finished_at: new Date().toISOString(),
                correct_count: correctCount,
                total_questions: totalQuestions,
            })
            .eq("id", sessionId)
            .eq("user_id", userId);

        if (error) throw new Error(`Update session failed: ${error.message}`);
    }
}

export const quizSessionService = new QuizSessionService();
