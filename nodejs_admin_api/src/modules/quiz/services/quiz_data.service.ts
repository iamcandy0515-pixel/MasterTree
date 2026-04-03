import { quizRepository } from "../quiz.repository";
import { quizQueryRepository } from "../quiz_query.repository";
import { quizAIService } from "../ai/quiz-ai.service";
import { UploadService } from "../../uploads/uploads.service";
import { QuizFormatter } from "../utils/quiz_formatter";
import { quizIdentityService } from "./quiz_identity.service";
import { QuizItem, ExamFilter } from "../types/quiz.types";

/**
 * Quiz Data Service
 * Handles persistence, batch processing, and data formatting for recommendations.
 * [Rule] Monitored to stay under 200 lines. Refactored QuizIdentityService to stay lean.
 */
export class QuizDataService {
    /**
     * Upserts a quiz question and handles AI embeddings.
     */
    async upsertQuizQuestion(data: any) {
        const categoryId = await quizIdentityService.ensureCategory(data.subject);
        const examId = await quizIdentityService.ensureExam(data.subject, data.year, data.round);
        const wrapBlock = (val: any) => Array.isArray(val) ? val : [{ type: "text", content: val || "" }];

        let finalId = data.id;
        let existingBlocks: any[] = [];
        
        if (!finalId && examId) {
            const { data: existing } = await quizQueryRepository.findQuestionsByExamAndNumbers(examId as number, [data.question_number]);
            if (existing && (existing as any[]).length > 0) {
                finalId = (existing as any[])[0].id;
                existingBlocks = (existing as any[])[0].content_blocks || [];
            }
        } else if (finalId) {
            const { data: existing } = await quizQueryRepository.findQuizForDeletion(finalId);
            existingBlocks = (existing as any)?.content_blocks || [];
        }

        const payload: any = {
            raw_source_text: data.raw_source_text,
            content_blocks: QuizFormatter.mergeBlocks(wrapBlock(data.content_blocks), existingBlocks),
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

        if (finalId) {
            await quizRepository.updateQuiz(finalId, payload);
            return { id: finalId, ...payload };
        } else {
            const res = await quizRepository.insertQuiz(payload);
            if (res.error) throw res.error;
            return { id: (res.data as any).id, ...payload };
        }
    }

    /**
     * Handles batch upsert of quiz questions.
     */
    async upsertQuizBatch(quizItems: any[], examFilter: ExamFilter) {
        const { subject, year, round } = examFilter;
        const categoryId = await quizIdentityService.ensureCategory(subject);
        const examId = await quizIdentityService.ensureExam(subject, year, round);

        if (!categoryId || !examId) {
            throw new Error(`Invalid identity resolution (categoryId=${categoryId}, examId=${examId}).`);
        }

        const qNumbers = quizItems.map(i => parseInt(i.question_number.toString(), 10));
        const { data: existingList } = await quizQueryRepository.findQuestionsByExamAndNumbers(examId, qNumbers);
        const existingMap = new Map((existingList as any[] || []).map(q => [q.question_number, q.content_blocks]));

        const itemsToUpsert: any[] = [];
        for (const item of quizItems) {
            const qNum = parseInt(item.question_number.toString(), 10);
            const payload: any = QuizFormatter.formatBatchItem(item, examId, categoryId, existingMap.get(qNum));
            const embedText = QuizFormatter.getEmbeddingSourceText(payload);
            if (embedText) {
                const embedding = await quizAIService.generateEmbedding(embedText);
                if (embedding) payload.embedding = embedding;
            }
            itemsToUpsert.push(payload);
        }

        const { data, error } = await quizRepository.upsertBatch(itemsToUpsert);
        if (error) throw new Error(`Batch save failed: ${error.message}`);
        return data;
    }

    /**
     * Formats database results into a single context string for AI recommendation.
     */
    async getFormattedCandidates(queryEmbedding: number[]): Promise<string> {
        let questions: any[] = [];
        if (queryEmbedding && queryEmbedding.length > 0) {
            const { data, error } = await quizQueryRepository.matchQuestions(queryEmbedding, 0.5, 50);
            if (!error && data && (data as any[]).length > 0) {
                const { data: fullData } = await quizQueryRepository.findQuizzesByIds((data as any[]).map((d: any) => d.id));
                questions = fullData || [];
            }
        }
        if (questions.length === 0) {
            const { data } = await quizQueryRepository.findRecentQuizzes(50);
            questions = data || [];
        }
        return questions.map((q: any) => {
            const text = (q.content_blocks as any[] || []).filter(b => b.type === "text").map(b => b.content || "").join(" ").substring(0, 150);
            const examStr = q.quiz_exams ? `${q.quiz_exams.year}년 ${q.quiz_exams.round}회 (${q.quiz_exams.title})` : "Unknown";
            return `ID: ${q.id} | [${examStr} | ${q.question_number}번] ${text}`;
        }).join("\n");
    }

    /**
     * Deletes a quiz and cleans up storage images.
     */
    async deleteQuiz(id: number) {
        const { data: quiz } = await quizQueryRepository.findQuizForDeletion(id) as any;
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
        const { page = 1, limit = 20, subject, year, round, minimal } = filter;
        const offset = (page - 1) * limit;

        const categoryId = subject ? await quizIdentityService.ensureCategory(subject) : undefined;
        const examId = (year && round) ? await quizIdentityService.ensureExam(subject, year, round) : undefined;

        const { data, error, count } = await quizQueryRepository.findWithFilters(offset, limit, { ...filter, categoryId, examId });
        if (error) throw error;

        const processedData = (data as any[]).map(quiz => {
            if (minimal) {
                const textBlock = quiz.content_blocks?.find((b: any) => b.type === "text");
                const imageBlock = quiz.content_blocks?.find((b: any) => b.type === "image");
                return {
                    id: quiz.id,
                    question_number: quiz.question_number,
                    difficulty: quiz.difficulty,
                    category: quiz.quiz_categories?.name,
                    exam_info: quiz.quiz_exams ? `${quiz.quiz_exams.year}년 ${quiz.quiz_exams.round}회` : null,
                    summary_text: textBlock?.content?.substring(0, 100) || "",
                    thumbnail_url: imageBlock?.image_url || null
                };
            }
            return quiz;
        });

        return { data: processedData, meta: { total: count || 0, page, limit, totalPages: count ? Math.ceil(count / limit) : 0 } };
    }
}

export const quizDataService = new QuizDataService();
