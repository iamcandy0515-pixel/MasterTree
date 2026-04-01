import { supabase } from "../../config/supabaseClient";

/**
 * Quiz Repository
 * Handles all direct database interactions for the Quiz module.
 * Following Rule 1-1 of DEVELOPMENT_RULES.md for source splitting and 200-line limit.
 */
export class QuizRepository {
    /**
     * Finds a quiz category by name
     */
    async findCategoryByName(name: string) {
        return await supabase
            .from("quiz_categories")
            .select("id")
            .eq("name", name)
            .maybeSingle();
    }

    /**
     * Creates a new quiz category
     */
    async createCategory(name: string) {
        return await supabase
            .from("quiz_categories")
            .insert([{ name }])
            .select("id")
            .single();
    }

    /**
     * Finds a quiz exam by title, year, and round
     */
    async findExam(title: string, year: number, round: number) {
        return await supabase
            .from("quiz_exams")
            .select("id")
            .eq("title", title)
            .eq("year", year)
            .eq("round", round)
            .maybeSingle();
    }

    /**
     * Creates a new quiz exam
     */
    async createExam(year: number, round: number, title: string) {
        return await supabase
            .from("quiz_exams")
            .insert([{ year, round, title }])
            .select("id")
            .single();
    }

    /**
     * Updates an existing quiz question
     */
    async updateQuiz(id: number, payload: any) {
        return await supabase
            .from("quiz_questions")
            .update(payload)
            .eq("id", id);
    }

    /**
     * Inserts a new quiz question
     */
    async insertQuiz(payload: any) {
        return await supabase
            .from("quiz_questions")
            .insert([payload])
            .select("id")
            .single();
    }

    /**
     * Upserts a batch of quiz questions
     */
    async upsertBatch(items: any[]) {
        // [DEBUG] Ensure we are using the Service Role at the moment of request
        const headers = (supabase as any).rest?.headers || {};
        const authHeader = headers['apikey'] || headers['Authorization'] || 'None';
        if (items.length > 0) {
            console.log(`[QuizRepo] Sample Item Structure (exam_id: ${items[0].exam_id}, category_id: ${items[0].category_id}, q_num: ${items[0].question_number})`);
        }

        const { data, error } = await supabase
            .from("quiz_questions")
            .upsert(items, {
                onConflict: "exam_id, question_number",
            })
            .select();

        if (error) {
            console.error("❌ [QuizRepo] DB Error Object:", JSON.stringify(error, null, 2));
        }
        return { data, error };
    }

    /**
     * Single item upsert (fallback or strict)
     */
    async upsertSingle(item: any) {
        return await supabase
            .from("quiz_questions")
            .upsert([item], {
                onConflict: "exam_id, question_number",
            })
            .select();
    }

    /**
     * Fetches full quiz data including image paths for deletion
     */
    async findQuizForDeletion(id: number) {
        return await supabase
            .from("quiz_questions")
            .select("*")
            .eq("id", id)
            .single();
    }

    /**
     * Deletes quiz record from DB
     */
    async deleteQuizRecord(id: number) {
        return await supabase
            .from("quiz_questions")
            .delete()
            .eq("id", id);
    }

    /**
     * Updates related IDs for a single quiz
     */
    async updateRelatedIds(quizId: number, relatedIds: number[]) {
        return await supabase
            .from("quiz_questions")
            .update({ related_quiz_ids: relatedIds })
            .eq("id", quizId);
    }

}

export const quizRepository = new QuizRepository();
