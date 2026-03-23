import { Request, Response } from "express";
import { quizService } from "./quiz.service";
import { successResponse, errorResponse } from "../../utils/response";

/**
 * Quiz Controller (Strategy D)
 * Handles standard CRUD and database orchestrations for the Quiz module.
 * Optimized for Rule 1-1 (200-line limit).
 */
export class QuizController {
    /**
     * listQuizzes (Placeholder for DB read)
     */
    async listQuizzes(req: Request, res: Response) {
        return successResponse(res, [], "Quizzes retrieved");
    }

    /**
     * Saves a quiz question to DB
     */
    async upsertQuizQuestion(req: Request, res: Response): Promise<void> {
        try {
            const data = req.body;
            const updated = await quizService.upsertQuizQuestion(data);
            return successResponse(res, updated, "Quiz question saved successfully.", 200);
        } catch (error: any) {
            console.error("[QuizCRUD] Upsert Error:", error.message);
            return errorResponse(res, "Failed to save quiz question: " + error.message, 500);
        }
    }

    /**
     * Upserts a batch of quiz questions
     */
    async upsertQuizBatch(req: Request, res: Response): Promise<void> {
        try {
            const { quizItems, examFilter } = req.body;
            if (!quizItems || !examFilter) return errorResponse(res, "quizItems and examFilter are required.", 400);

            const result = await quizService.upsertQuizBatch(quizItems, examFilter);
            return successResponse(res, result, "Batch of quizzes saved successfully.", 200);
        } catch (error: any) {
            console.error("[QuizCRUD] Batch Upsert Error:", error.message);
            const status = error.message.includes("DB_KEY_ERROR") ? 400 : 500;
            return errorResponse(res, error.message, status);
        }
    }

    /**
     * Upserts a batch of related quiz IDs
     */
    async upsertRelatedBulk(req: Request, res: Response): Promise<void> {
        try {
            const { relatedMap } = req.body;
            if (!relatedMap) return errorResponse(res, "relatedMap is required.", 400);

            await quizService.upsertRelatedBulk(relatedMap);
            return successResponse(res, { success: true }, "Bulk related quizzes saved successfully.", 200);
        } catch (error: any) {
            console.error("[QuizCRUD] Related Upsert Error:", error.message);
            return errorResponse(res, "Failed to save bulk related quizzes: " + error.message, 500);
        }
    }

    /**
     * Deletes a quiz question by ID
     */
    async deleteQuiz(req: Request, res: Response): Promise<void> {
        try {
            const { id } = req.params;
            if (!id) return errorResponse(res, "Quiz ID is required.", 400);

            await quizService.deleteQuiz(Number(id));
            return successResponse(res, { id }, "Quiz deleted successfully.", 200);
        } catch (error: any) {
            console.error("[QuizCRUD] Delete Error:", error.message);
            return errorResponse(res, "Failed to delete quiz: " + error.message, 500);
        }
    }
}

export const quizController = new QuizController();
