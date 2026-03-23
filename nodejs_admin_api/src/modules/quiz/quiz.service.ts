import { quizAIService } from "./ai/quiz-ai.service";
import { quizRepository } from "./quiz.repository";
import { quizExtractionService } from "./quiz-extraction.service";
import { quizDataService } from "./services/quiz_data.service";

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
     * Persistence & Business Logic (Delegated)
     */
    async upsertQuizQuestion(data: any) {
        return await quizDataService.upsertQuizQuestion(data);
    }

    async upsertQuizBatch(quizItems: any[], examFilter: any) {
        return await quizDataService.upsertQuizBatch(quizItems, examFilter);
    }

    async deleteQuiz(id: number) {
        return await quizDataService.deleteQuiz(id);
    }

    async upsertRelatedBulk(relatedMap: Record<string, number[]>) {
        await Promise.all(
            Object.entries(relatedMap).map(([quizId, ids]) => 
                quizRepository.updateRelatedIds(Number(quizId), ids)
            )
        );
    }

    /**
     * AI Recommendation & Vector Search
     */
    async recommendRelated(questionText: string, limitCount: number = 3) {
        const queryEmbedding = await quizAIService.generateEmbedding(questionText);
        let questions: any[] = [];

        if (queryEmbedding && queryEmbedding.length > 0) {
            const { data, error } = await quizRepository.matchQuestions(queryEmbedding, 0.5, 50);
            if (!error && data && (data as any[]).length > 0) {
                const { data: fullData } = await quizRepository.findQuizzesByIds((data as any[]).map((d: any) => d.id));
                questions = fullData || [];
            }
        }
        if (questions.length === 0) {
            const { data } = await quizRepository.findRecentQuizzes(50);
            questions = data || [];
        }

        const candidates = questions.map((q: any) => {
            const text = (q.content_blocks as any[]).filter(b => b.type === "text").map(b => b.content || "").join(" ").substring(0, 150);
            const examStr = q.quiz_exams ? `${q.quiz_exams.year}년 ${q.quiz_exams.round}회 (${q.quiz_exams.title})` : "Unknown";
            return `ID: ${q.id} | [${examStr} | ${q.question_number}번] ${text}`;
        }).join("\n");

        return await quizAIService.recommendRelated(questionText, candidates, limitCount);
    }
}

export const quizService = new QuizService();
