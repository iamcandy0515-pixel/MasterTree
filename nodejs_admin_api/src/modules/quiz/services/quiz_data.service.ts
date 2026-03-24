import { quizRepository } from "../quiz.repository";
import { quizAIService } from "../ai/quiz-ai.service";
import { UploadService } from "../../uploads/uploads.service";
import { QuizFormatter } from "../utils/quiz_formatter";

export class QuizDataService {
    /**
     * Ensures category exists or creates it.
     */
    async ensureCategory(subject: string) {
        if (!subject) return null;
        const { data } = await quizRepository.findCategoryByName(subject);
        if (data && (data as any).id) return (data as any).id;
        const { data: newCat } = await quizRepository.createCategory(subject);
        return (newCat as any)?.id;
    }

    /**
     * Ensures exam entity exists or creates it.
     */
    async ensureExam(subject: string, year: number, round: number) {
        if (!year || !round) return null;
        const examTitle = `${subject || "Unknown"} ${year}년 ${round}회`;
        const { data } = await quizRepository.findExam(examTitle, year, round);
        if (data && (data as any).id) return (data as any).id;
        const { data: newExam } = await quizRepository.createExam(year, round, examTitle);
        return (newExam as any)?.id;
    }

    /**
     * Upserts a quiz question and handles AI embeddings.
     */
    async upsertQuizQuestion(data: any) {
        const categoryId = await this.ensureCategory(data.subject);
        const examId = await this.ensureExam(data.subject, data.year, data.round);

        const payload: any = {
            raw_source_text: data.raw_source_text,
            content_blocks: data.content_blocks,
            hint_blocks: data.hint_blocks,
            options: data.options,
            correct_option_index: data.correct_option_index,
            explanation_blocks: data.explanation_blocks,
            difficulty: data.difficulty || 1,
            status: "draft",
            category_id: categoryId,
            exam_id: examId,
            question_number: data.question_number,
            related_quiz_ids: data.related_quiz_ids,
        };

        const embedText = QuizFormatter.getEmbeddingSourceText(data);
        if (embedText) {
            const embedding = await quizAIService.generateEmbedding(embedText);
            if (embedding) payload.embedding = embedding;
        }

        if (data.id) {
            await quizRepository.updateQuiz(data.id, payload);
            return { id: data.id, ...payload };
        } else {
            const res = await quizRepository.insertQuiz(payload);
            if (res.error) throw res.error;
            return { id: (res.data as any).id, ...payload };
        }
    }

    /**
     * Handles batch upsert of quiz questions.
     * Atomic: All or nothing via supabase-js batch upsert.
     */
    async upsertQuizBatch(quizItems: any[], examFilter: any) {
        const { subject, year, round } = examFilter;
        const categoryId = await this.ensureCategory(subject);
        const examId = await this.ensureExam(subject, year, round);

        const itemsToUpsert: any[] = [];
        for (const item of quizItems) {
            const payload: any = QuizFormatter.formatBatchItem(item, examId, categoryId);
            const embedText = QuizFormatter.getEmbeddingSourceText(payload);
            if (embedText) {
                const embedding = await quizAIService.generateEmbedding(embedText);
                if (embedding) payload.embedding = embedding;
            }
            itemsToUpsert.push(payload);
        }

        const { data, error } = await quizRepository.upsertBatch(itemsToUpsert);
        if (error) {
            console.error(`[QuizDataService] Atomic Batch Upsert Failed:`, error.message);
            throw new Error(`Batch save failed: ${error.message}`);
        }
        return data;
    }

    /**
     * Deletes a quiz and cleans up storage images.
     */
    async deleteQuiz(id: number) {
        const { data: quiz } = await quizRepository.findQuizForDeletion(id) as any;
        if (quiz) {
            const imagePaths = QuizFormatter.extractImagePaths([...(quiz.content_blocks || []), ...(quiz.explanation_blocks || [])]);
            if (imagePaths.length > 0) {
                await UploadService.deleteFromStorage([...new Set(imagePaths)]).catch(e => console.warn(`[Cleanup] Failed for quiz ${id}:`, e));
            }
        }
        const { error } = await quizRepository.deleteQuizRecord(id);
        if (error) throw new Error("Failed to delete quiz: " + error.message);
    }

    /**
     * listQuizzes: Filtered & Paginated Search with Mobile Optimization
     */
    async listQuizzes(filter: any) {
        const { page, limit, subject, year, round, minimal } = filter;
        const offset = (page - 1) * limit;

        // Resolve IDs for filtering if provided
        const categoryId = subject ? await this.ensureCategory(subject) : undefined;
        const examId = (year && round) ? await this.ensureExam(subject, year, round) : undefined;

        const { data, error, count } = await quizRepository.findWithFilters(offset, limit, {
            ...filter,
            categoryId,
            examId
        });

        if (error) throw error;

        // Apply Mobile Optimization: Field Pruning & Thumbnail Mapping
        const processedData = (data as any[]).map(quiz => {
            if (minimal) {
                return {
                    id: quiz.id,
                    question_number: quiz.question_number,
                    difficulty: quiz.difficulty,
                    category: quiz.quiz_categories?.name,
                    exam_info: quiz.quiz_exams ? `${quiz.quiz_exams.year}년 ${quiz.quiz_exams.round}회` : null,
                    // Prune content_blocks to first text block only for list view
                    summary_text: quiz.content_blocks?.find((b: any) => b.type === "text")?.content?.substring(0, 100) || "",
                    // Thumbnail mapping for first image found
                    thumbnail_url: quiz.content_blocks?.find((b: any) => b.type === "image")?.image_url || null
                };
            }
            return quiz;
        });

        return {
            data: processedData,
            meta: { total: count || 0, page, limit, totalPages: count ? Math.ceil(count / limit) : 0 }
        };
    }
}

export const quizDataService = new QuizDataService();
