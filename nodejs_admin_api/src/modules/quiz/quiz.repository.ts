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
        return await supabase
            .from("quiz_questions")
            .upsert(items, {
                onConflict: "exam_id, question_number",
            })
            .select();
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
     * Performs vector search for related questions
     */
    async matchQuestions(embedding: number[], threshold: number, count: number) {
        return await supabase.rpc("match_quiz_questions", {
            query_embedding: embedding,
            match_threshold: threshold,
            match_count: count,
        });
    }

    /**
     * Fetches basic info for multiple quiz IDs
     */
    async findQuizzesByIds(ids: number[]) {
        return await supabase
            .from("quiz_questions")
            .select(
                `id, question_number, content_blocks, quiz_exams(year, round, title)`,
            )
            .in("id", ids);
    }

    /**
     * Fetches recent quizzes as fallback candidates
     */
    async findRecentQuizzes(limit: number) {
        return await supabase
            .from("quiz_questions")
            .select(
                `id, question_number, content_blocks, quiz_exams(year, round, title)`,
            )
            .limit(limit)
            .order("created_at", { ascending: false });
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

    /**
     * Finds quizzes with pagination and filters
     */
    async findWithFilters(offset: number, limit: number, filters: any) {
        let query = supabase
            .from("quiz_questions")
            .select(
                `
                id, question_number, content_blocks, options, correct_option_index, 
                explanation_blocks, difficulty, category_id, exam_id,
                quiz_categories(name), quiz_exams(year, round, title)
                `,
                { count: "exact" },
            );

        if (filters.difficulty) query = query.eq("difficulty", filters.difficulty);
        if (filters.search) {
            query = query.ilike("raw_source_text", `%${filters.search}%`);
        }
        
        // Relationship filters often require sub-selects or separate ID IDs in Supabase
        if (filters.categoryId) query = query.eq("category_id", filters.categoryId);
        if (filters.examId) query = query.eq("exam_id", filters.examId);

        return await query
            .range(offset, offset + limit - 1)
            .order("id", { ascending: false });
    }
}

export const quizRepository = new QuizRepository();
