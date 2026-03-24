import { Request, Response } from "express";
import { quizService } from "../quiz.service";
import { successResponse, errorResponse } from "../../../utils/response";

/**
 * Quiz Management Controller
 * Handles individual quiz CRUD operations.
 */
export class QuizManagementController {
    /**
     * upsertQuizQuestion: Save or update a single question
     */
    static async upsertQuizQuestion(req: Request, res: Response) {
        try {
            const data = req.body;
            if (!data.question_text) return errorResponse(res, "question_text is required", 400);

            const updated = await quizService.upsertQuizQuestion(data);
            return successResponse(res, updated, "Quiz question saved successfully.", 200);
        } catch (error: any) {
            console.error("[QuizManagement] Upsert Error:", error.message);
            return errorResponse(res, "Failed to save quiz question: " + error.message, 500);
        }
    }

    /**
     * deleteQuiz: Single deletion by ID
     */
    static async deleteQuiz(req: Request, res: Response) {
        try {
            const { id } = req.params;
            if (!id) return errorResponse(res, "Quiz ID is required.", 400);

            await quizService.deleteQuiz(Number(id));
            return successResponse(res, { id: Number(id) }, "Quiz deleted successfully.", 200);
        } catch (error: any) {
            console.error("[QuizManagement] Delete Error:", error.message);
            return errorResponse(res, "Failed to delete quiz: " + error.message, 500);
        }
    }
}
