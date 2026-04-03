import { quizAIService } from "./ai/quiz-ai.service";
import { quizRepository } from "./quiz.repository";
import { quizExtractionService } from "./quiz-extraction.service";
import { quizDataService } from "./services/quiz_data.service";
import { QuizItem, ExamFilter, QuizRecommendation } from "./types/quiz.types";

/**
 * Quiz Service (Orchestrator)
 * Central entry point for the Quiz module, delegating complex logic to specialized AI, Extraction, and Data layers.
 * Adheres strictly to the 200-line limit from DEVELOPMENT_RULES.md.
 */
export class QuizService {
    /**
     * AI Parsing & Distractor Generation
     */
    async parseRawSourceToQuizBlocks(rawText: string) {
        return await quizAIService.parseRawSource(rawText);
    }

    async generateDistractor(questionText: string, correctOption: string, optionsCount: number = 3) {
        return await quizAIService.generateDistractor(questionText, correctOption, optionsCount);
    }

    async generateHints(questionText: string, explanation: string, count: number = 2) {
        return await quizAIService.generateHints(questionText, explanation, count);
    }

    async reviewQuizAlignment(rawText: string, currentQuizBlocks: any) {
        return await quizAIService.reviewAlignment(rawText, currentQuizBlocks);
    }

    /**
     * PDF Extraction
     */
    async validateQuizPdfFile(pdfBuffer: Buffer, subject?: string, year?: number, round?: number) {
        return await quizExtractionService.validatePdfMetadata(pdfBuffer, { subject, year, round });
    }

    async extractQuizFromPdfBuffer(pdfBuffer: Buffer, questionNumber: number, optionsCount: number) {
        return await quizExtractionService.extractSingleFromBuffer(pdfBuffer, questionNumber, optionsCount);
    }

    async extractQuizBatchFromPdf(pdfBuffer: Buffer, start: number, end: number, subject: string, year: number, round: number) {
        return await quizExtractionService.extractBatchFromBuffer(pdfBuffer, start, end, { subject, year, round });
    }

    /**
     * Persistence & Business Logic
     */
    async upsertQuizQuestion(data: QuizItem) {
        try {
            return await quizDataService.upsertQuizQuestion(data);
        } catch (error) {
            console.error("[QuizService] Upsert failed:", error);
            throw error;
        }
    }

    async upsertQuizBatch(quizItems: QuizItem[], examFilter: ExamFilter) {
        try {
            return await quizDataService.upsertQuizBatch(quizItems, examFilter);
        } catch (error) {
            console.error("[QuizService] Batch upsert failed:", error);
            throw error;
        }
    }

    async deleteQuiz(id: number) {
        try {
            return await quizDataService.deleteQuiz(id);
        } catch (error) {
            console.error(`[QuizService] Delete failed (ID: ${id}):`, error);
            throw error;
        }
    }

    async upsertRelatedBulk(relatedMap: Record<string, number[]>) {
        await Promise.all(
            Object.entries(relatedMap).map(([quizId, ids]) => 
                quizRepository.updateRelatedIds(Number(quizId), ids)
            )
        );
    }

    /**
     * listQuizzes: Filtered & Paginated Search
     */
    async listQuizzes(filter: any) {
        return await quizDataService.listQuizzes(filter);
    }

    /**
     * AI Recommendation & Vector Search
     * [Refactored] Implementation logic moved to QuizDataService to keep this orchestrator lean.
     */
    async recommendRelated(questionText: string, limitCount: number = 3): Promise<QuizRecommendation[]> {
        try {
            const queryEmbedding = await quizAIService.generateEmbedding(questionText);
            if (!queryEmbedding || queryEmbedding.length === 0) return [];

            const candidates = await quizDataService.getFormattedCandidates(queryEmbedding);
            return await quizAIService.recommendRelated(questionText, candidates, limitCount);
        } catch (error) {
            console.error("[QuizService] Recommendation failed:", error);
            return [];
        }
    }
}

export const quizService = new QuizService();
