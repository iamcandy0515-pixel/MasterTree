import { supabase } from "../../config/supabaseClient";

/**
 * Quiz Query Repository
 * Handles search, filtering, and complex read operations for the Quiz module.
 * Extracted from quiz.repository.ts to comply with Rule 1-1 (200-line limit).
 */
export class QuizQueryRepository {
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
        
        if (filters.categoryId) query = query.eq("category_id", filters.categoryId);
        if (filters.examId) query = query.eq("exam_id", filters.examId);

        return await query
            .range(offset, offset + limit - 1)
            .order("id", { ascending: false });
    }

    /**
     * Fetches questions by exam ID and a list of question numbers
     */
    async findQuestionsByExamAndNumbers(examId: number, questionNumbers: number[]) {
        return await supabase
            .from("quiz_questions")
            .select("id, question_number, content_blocks, explanation_blocks, hint_blocks")
            .eq("exam_id", examId)
            .in("question_number", questionNumbers);
    }
}

export const quizQueryRepository = new QuizQueryRepository();
