import { Request, Response } from "express";
import { quizService } from "../quiz.service";
import { successResponse, errorResponse } from "../../../utils/response";

/**
 * Quiz Search Controller
 * Handles paginated listings, filtering, and mobile-optimized payloads.
 */
export class QuizSearchController {
    /**
     * listQuizzes: Supports pagination, filtering, and 'minimal' mode for mobile performance.
     */
    static async listQuizzes(req: Request, res: Response) {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 20;
            const subject = req.query.subject as string;
            const year = parseInt(req.query.year as string);
            const round = parseInt(req.query.round as string);
            const difficulty = parseInt(req.query.difficulty as string);
            const search = req.query.search as string;
            const minimal = req.query.minimal === "true";

            const result = await quizService.listQuizzes({
                page,
                limit,
                subject,
                year: isNaN(year) ? undefined : year,
                round: isNaN(round) ? undefined : round,
                difficulty: isNaN(difficulty) ? undefined : difficulty,
                search,
                minimal
            });

            return successResponse(res, result.data, "Quizzes retrieved successfully", 200, result.meta);
        } catch (error: any) {
            console.error("[QuizSearch] List Error:", error.message);
            return errorResponse(res, "Failed to retrieve quizzes: " + error.message, 500);
        }
    }
}
