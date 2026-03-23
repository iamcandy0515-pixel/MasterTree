import { Request, Response } from "express";
import { quizService } from "./quiz.service";
import { quizAIService } from "./ai/quiz-ai.service";
import { successResponse, errorResponse } from "../../utils/response";

/**
 * Quiz AI Controller (Strategy E)
 * Handles AI-driven content generation, parsing, and recommendations.
 * Optimized for Rule 1-1 (200-line limit) and Rule 3 (Performance).
 */
export class QuizAIController {
    /**
     * Parses raw PDF/Text source into structured quiz JSON blocks
     */
    async parseRawSource(req: Request, res: Response): Promise<void> {
        try {
            const { rawText } = req.body;
            if (!rawText) return errorResponse(res, "rawText is required.", 400);

            // Direct call to QuizAIService via QuizService orchestrator
            const parsedBlocks = await quizService.parseRawSourceToQuizBlocks(rawText);

            return successResponse(res, { parsedBlocks }, "Raw source successfully parsed to quiz format.", 200);
        } catch (error: any) {
            console.error("[QuizAI] Parse Error:", error.message);
            return errorResponse(res, "Failed to parse raw source: " + error.message, 500);
        }
    }

    /**
     * Gets new incorrect distractors via AI Assistant
     */
    async generateDistractor(req: Request, res: Response): Promise<void> {
        try {
            const { questionText, correctOption } = req.body;
            if (!questionText || !correctOption) return errorResponse(res, "questionText and correctOption are required.", 400);

            const distractors = await quizService.generateDistractor(questionText, correctOption);

            return successResponse(res, { distractors }, "Distractors generated successfully.", 200);
        } catch (error: any) {
            console.error("[QuizAI] Distractor Gen Error:", error.message);
            return errorResponse(res, "Failed to generate distractors: " + error.message, 500);
        }
    }

    /**
     * Gets new hints via AI Assistant
     */
    async generateHints(req: Request, res: Response): Promise<void> {
        try {
            const { questionText, explanation, count } = req.body;
            if (!questionText || !explanation) return errorResponse(res, "questionText and explanation are required.", 400);

            const hints = await quizService.generateHints(questionText, explanation, count || 2);

            return successResponse(res, { hints }, "Hints generated successfully.", 200);
        } catch (error: any) {
            console.error("[QuizAI] Hint Gen Error:", error.message);
            return errorResponse(res, "Failed to generate hints: " + error.message, 500);
        }
    }

    /**
     * Gets related questions via AI search based on current question
     */
    async recommendRelated(req: Request, res: Response): Promise<void> {
        try {
            const { questionText, limit } = req.body;
            if (!questionText) return errorResponse(res, "questionText is required.", 400);

            const related = await quizService.recommendRelated(questionText, limit || 3);

            return successResponse(res, { related }, "Related questions retrieved successfully.", 200);
        } catch (error: any) {
            console.error("[QuizAI] Recommend Related Error:", error.message);
            return errorResponse(res, "Failed to recommend related questions: " + error.message, 500);
        }
    }

    /**
     * Reviews the alignment between original raw text and the edited quiz content
     */
    async reviewQuizAlignment(req: Request, res: Response): Promise<void> {
        try {
            const { rawText, currentQuizBlocks } = req.body;
            if (!rawText || !currentQuizBlocks) return errorResponse(res, "rawText and currentQuizBlocks are required.", 400);

            const reviewResult = await quizService.reviewQuizAlignment(rawText, currentQuizBlocks);

            return successResponse(res, { reviewResult }, "Quiz alignment review complete.", 200);
        } catch (error: any) {
            console.error("[QuizAI] Review Error:", error.message);
            return errorResponse(res, "Failed to review quiz alignment: " + error.message, 500);
        }
    }
}

export const quizAIController = new QuizAIController();
