import { Request, Response } from "express";
import { quizService } from "../quiz.service";
import { successResponse, errorResponse } from "../../../utils/response";

/**
 * Quiz Bulk Controller
 * Handles batch operations and cross-linking between quizzes.
 */
export class QuizBulkController {
    /**
     * upsertQuizBatch: High-volume quiz saving
     */
    static async upsertQuizBatch(req: Request, res: Response) {
        try {
            const { quizItems, examFilter } = req.body;
            if (!quizItems || !examFilter) return errorResponse(res, "quizItems and examFilter are required.", 400);

            // Forward to service which will handle DB Transaction
            const result = await quizService.upsertQuizBatch(quizItems, examFilter);
            return successResponse(res, result, "Batch of quizzes saved successfully.", 200);
        } catch (error: any) {
            console.error("[QuizBulk] Batch Upsert Error:", error.message);
            const status = error.message.includes("DB_KEY_ERROR") ? 400 : 500;
            return errorResponse(res, error.message, status);
        }
    }

    /**
     * upsertRelatedBulk: Mapping similar quizzes for AI/UI recommendations
     */
    static async upsertRelatedBulk(req: Request, res: Response) {
        try {
            const { relatedMap } = req.body;
            if (!relatedMap) return errorResponse(res, "relatedMap is required.", 400);

            await quizService.upsertRelatedBulk(relatedMap);
            return successResponse(res, { success: true }, "Bulk related quizzes saved successfully.", 200);
        } catch (error: any) {
            console.error("[QuizBulk] Related Upsert Error:", error.message);
            return errorResponse(res, "Failed to save bulk related quizzes: " + error.message, 500);
        }
    }
}
