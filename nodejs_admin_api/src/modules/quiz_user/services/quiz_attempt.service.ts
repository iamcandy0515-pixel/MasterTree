import { supabase } from "../../../config/supabaseClient";
import { quizSessionService } from "./quiz_session.service";
import { maintenanceService } from "../../system/services/maintenance.service";

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
            .insert(attemptRows);
        if (insErr) throw new Error(`Insert attempts failed: ${insErr.message}`);
        
        // Update Statistics Summary (Upsert)
        await this.syncSummary(userId, attempts);

        const correctCount = attemptRows.filter((a) => a.is_correct).length;
        const totalQuestions = attemptRows.length;

        await quizSessionService.updateSessionStats(userId, sessionId, correctCount, totalQuestions);
        
        // Probabilistic Background Maintenance (approx. 5% probability)
        if (Math.random() < 0.05) {
            maintenanceService.executeStatsPurge().catch(e => console.error("Purge Error:", e));
        }

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

        const { error: insErr } = await supabase.from("quiz_attempts").insert(attemptRows);
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
     * Sync latest attempt result to user_quiz_summary table and update aggregation tables.
     */
    private async syncSummary(userId: string, attempts: any[]) {
        const summaryRows = attempts.map(a => ({
            user_id: userId,
            question_id: a.question_id || null,
            is_last_correct: a.is_correct,
            tree_id: a.tree_id || null,
            updated_at: new Date().toISOString()
        })).filter(r => (r.question_id !== null) || (r.tree_id !== null));

        if (summaryRows.length === 0) return;

        const uniqueSummaries = Array.from(
            new Map(summaryRows.map(s => [s.question_id ? `q_${s.question_id}` : `t_${s.tree_id}`, s])).values()
        );

        const { error } = await supabase
            .from("user_quiz_summary")
            .upsert(uniqueSummaries);
        
        if (error) {
            console.error(`[SyncSummary] Failed to upsert:`, error.message);
            return;
        }

        // [New] Update Aggregation Statistics
        const hasTreeAttempts = attempts.some(a => a.tree_id);
        const hasExamAttempts = attempts.some(a => a.question_id);

        if (hasTreeAttempts) {
            await this.updateTreeCategoryStats(userId);
        }
        if (hasExamAttempts) {
            await this.updateExamSessionStats(userId);
        }
    }

    /**
     * Aggregates tree quiz results by category and updates user_tree_category_stats.
     */
    private async updateTreeCategoryStats(userId: string) {
        try {
            const { data: treeStats, error: statErr } = await supabase.rpc('get_user_tree_category_stats', { p_user_id: userId });
            
            if (statErr) {
                console.error(`[updateTreeCategoryStats] RPC error:`, statErr.message);
                return;
            }

            if (treeStats && treeStats.length > 0) {
                const upsertRows = treeStats.map((s: any) => ({
                    user_id: userId,
                    category_name: s.display_name,
                    total_count: Number(s.total_count),
                    mastered_count: Number(s.mastered_count),
                    in_progress_count: Number(s.in_progress_count),
                    accuracy_rate: s.total_count > 0 ? (Number(s.mastered_count) / Number(s.total_count)) * 100 : 0,
                    updated_at: new Date().toISOString()
                }));

                await supabase.from("user_tree_category_stats").upsert(upsertRows, { onConflict: 'user_id,category_name' });
            }
        } catch (err: any) {
            console.error(`[updateTreeCategoryStats] Error:`, err.message);
        }
    }

    /**
     * Aggregates exam results by session and updates user_exam_session_stats.
     */
    private async updateExamSessionStats(userId: string) {
        try {
            const { data: examStats, error: statErr } = await supabase.rpc('get_user_exam_session_stats', { p_user_id: userId });
            
            if (statErr) {
                console.error(`[updateExamSessionStats] RPC error:`, statErr.message);
                return;
            }

            if (examStats && examStats.length > 0) {
                const upsertRows = examStats.map((s: any) => ({
                    user_id: userId,
                    exam_id: s.exam_id,
                    subject_name: s.subject_name || s.exam_title,
                    total_count: Number(s.total_count),
                    mastered_count: Number(s.mastered_count),
                    in_progress_count: Number(s.in_progress_count),
                    accuracy_rate: s.total_count > 0 ? (Number(s.mastered_count) / Number(s.total_count)) * 100 : 0,
                    updated_at: new Date().toISOString()
                }));

                await supabase.from("user_exam_session_stats").upsert(upsertRows, { onConflict: 'user_id,exam_id' });
            }
        } catch (err: any) {
            console.error(`[updateExamSessionStats] Error:`, err.message);
        }
    }
}

export const quizAttemptService = new QuizAttemptService();


