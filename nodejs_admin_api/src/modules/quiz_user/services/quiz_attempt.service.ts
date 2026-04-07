import { supabase } from "../../../config/supabaseClient";
import { quizSessionService } from "./quiz_session.service";

export class QuizAttemptService {
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
            .insert(attemptRows as any[]);
        if (insErr) throw new Error(`Insert attempts failed: ${insErr.message}`);
        
        // Update Statistics Summary (Upsert)
        await this.syncSummary(userId, attempts);

        const correctCount = attemptRows.filter((a) => a.is_correct).length;
        const totalQuestions = attemptRows.length;

        await quizSessionService.updateSessionStats(userId, sessionId, correctCount, totalQuestions);
        return { correctCount, total: totalQuestions };
    }

    /**
     * Save a batch of attempts (Sync)
     * Corrected to use 'mode' and 'finished_at'
     */
    async saveBatchAttempts(userId: string, attempts: any[]) {
        if (!attempts || attempts.length === 0) return { success: true };

        const qAttempts = attempts.filter((a) => a.question_id !== undefined && a.question_id !== null);
        const tAttempts = attempts.filter((a) => a.tree_id !== undefined && a.tree_id !== null && (a.question_id === undefined || a.question_id === null));

        const qIds = [...new Set(qAttempts.map((a) => a.question_id))];
        let validQIdSet = new Set<number>();
        if (qIds.length > 0) {
            const { data: vQs, error: qsErr } = await supabase.from("quiz_questions").select("id").in("id", qIds);
            if (qsErr) throw new Error(`Validation failed: ${qsErr.message}`);
            validQIdSet = new Set(vQs?.map((q) => q.id) || []);
        }

        const tIds = [...new Set(tAttempts.map((a) => a.tree_id))];
        let validTIdSet = new Set<number>();
        if (tIds.length > 0) {
            const { data: vTs, error: tsErr } = await supabase.from("trees").select("id").in("id", tIds);
            if (tsErr) throw new Error(`Tree validation failed: ${tsErr.message}`);
            validTIdSet = new Set(vTs?.map((t) => t.id) || []);
        }

        const allFiltered = [
            ...qAttempts.filter((a) => validQIdSet.has(a.question_id)),
            ...tAttempts.filter((a) => validTIdSet.has(a.tree_id))
        ];

        if (allFiltered.length === 0) return { success: true, count: 0, filtered: attempts.length };

        const mode = allFiltered.some((a) => a.mode === "pastExam") ? "pastExam" : "normal";
        const sessionId = await quizSessionService.getOrCreateSession(userId, mode);

        const attemptRows = allFiltered.map((a) => ({
            session_id: sessionId,
            user_id: userId,
            question_id: a.question_id || null,
            tree_id: a.tree_id || null,
            category_id: a.category_id || null,
            is_correct: a.is_correct,
            user_answer: a.user_answer?.toString() || "",
            time_taken_ms: a.time_taken_ms || 0,
            created_at: a.created_at || new Date().toISOString(),
        }));

        const { error: insErr } = await supabase.from("quiz_attempts").insert(attemptRows as any[]);
        if (insErr) throw new Error(`Batch insert failed: ${insErr.message}`);

        // Update Statistics Summary (Upsert)
        await this.syncSummary(userId, allFiltered);

        const correctCount = attemptRows.filter((a) => a.is_correct).length;
        const { data: currentSession } = await supabase.from("quiz_sessions").select("correct_count, total_questions").eq("id", sessionId).single();

        await supabase.from("quiz_sessions").update({
            correct_count: (currentSession?.correct_count || 0) + correctCount,
            total_questions: (currentSession?.total_questions || 0) + attemptRows.length,
            finished_at: new Date().toISOString(),
        }).eq("id", sessionId);

        return { success: true, count: attemptRows.length, filtered: attempts.length - allFiltered.length };
    }

    /**
     * Sync latest attempt result to user_quiz_summary table.
     */
    private async syncSummary(userId: string, attempts: any[]) {
        // [1] 문제 번호(question_id) 또는 나무 번호(tree_id) 중 하나라도 있으면 통계 대상으로 수용
        const summaryRows = attempts.map(a => ({
            user_id: userId,
            question_id: a.question_id || null, // null 가능하도록 허용
            is_last_correct: a.is_correct,
            tree_id: a.tree_id || null,
            updated_at: new Date().toISOString()
        })).filter(r => (r.question_id !== null) || (r.tree_id !== null));

        if (summaryRows.length === 0) return;

        // [2] 배치 내에서 동일 항목에 대해 중복이 발생하면 마지막 결과를 사용
        // 식별자: question_id가 있으면 question_id, 없으면 tree_id 사용
        const uniqueSummaries = Array.from(
            new Map(summaryRows.map(s => [s.question_id ? `q_${s.question_id}` : `t_${s.tree_id}`, s])).values()
        );

        // [3] DB 업데이트 (UPSERT)
        // Note: DB 수준에서 (user_id, question_id) 혹은 (user_id, tree_id) 유니크 인덱스가 필요함
        // 여기서는 기존 로직의 안성을 보장하며 tree_id 기반 업데이트도 시도
        const { error } = await supabase
            .from("user_quiz_summary" as any)
            .upsert(uniqueSummaries); // onConflict를 명시하지 않으면 테이블 정의의 Primary Key 혹은 Unique 인덱스를 따름
        
        if (error) {
            console.error(`[SyncSummary] Failed to upsert:`, error.message);
        }
    }
}

export const quizAttemptService = new QuizAttemptService();
