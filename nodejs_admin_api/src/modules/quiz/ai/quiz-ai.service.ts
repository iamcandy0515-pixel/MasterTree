import { geminiGenerateText, geminiEmbedText, geminiExtractFromPdfBuffer } from "../../../config/geminiClient";
import { QuizPrompts } from "./quiz.prompts";

/**
 * Quiz AI Service (Strategy A)
 * Specialized in AI model interactions and output refinement.
 * Following Rule 1-1 of DEVELOPMENT_RULES.md (200-line limit).
 */
export class QuizAIService {
    /**
     * Parses raw text into structured quiz format using AI
     */
    async parseRawSource(rawText: string) {
        const prompt = QuizPrompts.PARSE_RAW_SOURCE(rawText);
        try {
            return await geminiGenerateText(prompt);
        } catch (error) {
            console.error("[QuizAI] Parse Error:", error);
            throw new Error("Failed to parse raw text into quiz format.");
        }
    }

    /**
     * Re-generates distractors for a specific question
     */
    async generateDistractor(questionText: string, correctOption: string, optionsCount: number = 3) {
        const prompt = QuizPrompts.GENERATE_DISTRACTOR(questionText, correctOption, optionsCount);
        try {
            return await geminiGenerateText(prompt);
        } catch (error) {
            console.error("[QuizAI] Distractor Gen Error:", error);
            throw new Error("Failed to generate distractors.");
        }
    }

    /**
     * Reviews the alignment between raw text and quiz data
     */
    async reviewAlignment(rawText: string, currentQuizBlocks: any) {
        const prompt = QuizPrompts.REVIEW_ALIGNMENT(rawText, JSON.stringify(currentQuizBlocks, null, 2));
        try {
            return await geminiGenerateText(prompt);
        } catch (error) {
            console.error("[QuizAI] Review Error:", error);
            throw new Error("Failed to review quiz alignment.");
        }
    }

    /**
     * Validates PDF metadata match against subject/year/round
     */
    async validatePdfFilter(pdfBase64: string, filterStr: string) {
        const prompt = QuizPrompts.VALIDATE_PDF_FILTER(filterStr);
        try {
            return await geminiExtractFromPdfBuffer(pdfBase64, prompt);
        } catch (error: any) {
            console.error("[QuizAI] PDF Validate Error:", error);
            throw new Error(error.message || "Failed to validate PDF filter.");
        }
    }

    /**
     * Extracts a single quiz item from a PDF
     */
    async extractSingleQuiz(pdfBase64: string, questionNumber: number, optionsCount: number) {
        const qNumStr = questionNumber.toString();
        const qNumPadded = qNumStr.padStart(2, "0");
        const prompt = QuizPrompts.EXTRACT_SINGLE_QUIZ(questionNumber, qNumStr, qNumPadded, optionsCount);
        try {
            return await geminiExtractFromPdfBuffer(pdfBase64, prompt);
        } catch (error: any) {
            console.error("[QuizAI] Single Extract Error:", error);
            throw new Error(error.message || "Failed to extract quiz from PDF.");
        }
    }

    /**
     * Generates hints for a question
     */
    async generateHints(questionText: string, explanation: string, count: number = 2) {
        const prompt = QuizPrompts.GENERATE_HINTS(questionText, explanation, count);
        try {
            return await geminiGenerateText(prompt);
        } catch (error) {
            console.error("[QuizAI] Hint Gen Error:", error);
            throw new Error("Failed to generate hints.");
        }
    }

    /**
     * Selects related questions from candidates via AI
     */
    async recommendRelated(questionText: string, candidatesText: string, limitCount: number) {
        const prompt = QuizPrompts.RECOMMEND_RELATED(questionText, candidatesText, limitCount);
        try {
            const result = await geminiGenerateText(prompt);
            return result.map((r: any) => ({
                id: r.id,
                year: r.year || 0,
                round: r.round || 0,
                subject: r.subject || "기출문제",
                question_number: r.question_number || 0,
                question: r.question,
                reason: r.reason || "유사한 주제로 분류됨",
            }));
        } catch (error) {
            console.error("[QuizAI] Recommend AI Error:", error);
            return [];
        }
    }

    /**
     * Generates vector embedding for technical text
     */
    async generateEmbedding(text: string) {
        try {
            return await geminiEmbedText(text);
        } catch (error) {
            console.error("[QuizAI] Embedding Failed:", error);
            return null;
        }
    }

    /**
     * Extracts multi-item batch from PDF (Gemini call)
     */
    async extractBatchItems(pdfBase64: string, start: number, end: number) {
        const prompt = QuizPrompts.BATCH_EXTRACT(start, end);
        try {
            return await geminiExtractFromPdfBuffer(pdfBase64, prompt);
        } catch (error) {
            console.error(`[QuizAI] Batch Extract Error for ${start}~${end}:`, error);
            return { error: "Failed to extract batch items" };
        }
    }
}

export const quizAIService = new QuizAIService();
