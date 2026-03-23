import { Request, Response } from "express";
import { quizUserService } from "./quiz_user.service";
import { successResponse, errorResponse } from "../../utils/response";
import { supabase } from "../../config/supabaseClient";

export class QuizUserController {
    /**
     * POST /api/user-quiz/generate
     * Generate a new quiz session
     */
    async generateSession(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).user.id;
            const { mode, limit } = req.body; // Changed from session_type

            const result = await quizUserService.generateSession(
                userId,
                mode || "normal",
                limit,
            );
            return successResponse(res, result, "Quiz session generated");
        } catch (error: any) {
            console.error("Generate Session Error:", error);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * POST /api/user-quiz/submit
     * Submit session attempts
     */
    async submitAttempts(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).user.id;
            const { session_id, attempts } = req.body;

            if (!session_id || !attempts) {
                return errorResponse(
                    res,
                    "Missing session_id or attempts",
                    400,
                );
            }

            const result = await quizUserService.submitAttempts(
                userId,
                session_id,
                attempts,
            );
            return successResponse(
                res,
                result,
                "Attempts submitted successfully",
            );
        } catch (error: any) {
            console.error("Submit Attempts Error:", error);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * GET /api/user-quiz/stats
     * Get user dashboard stats
     */
    async getStats(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).user.id;
            const result = await quizUserService.getAggregatedStats(userId);
            return successResponse(res, result, "Stats retrieved successfully");
        } catch (error: any) {
            console.error("Get Stats Error:", error);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * GET /api/user-quiz/incorrect-notes
     */
    async getIncorrectNotes(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).user.id;
            const { data, error } = await supabase
                .from("quiz_attempts")
                .select(
                    `
                    *,
                    quiz_questions (
                        content_blocks,
                        options,
                        explanation_blocks
                    )
                `,
                )
                .eq("user_id", userId)
                .eq("is_correct", false)
                .order("created_at", { ascending: false })
                .limit(50);

            if (error) throw error;
            return successResponse(res, data, "Incorrect notes retrieved");
        } catch (error: any) {
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * POST /api/user-quiz/attempt
     * Save single attempt (legacy/standalone)
     */
    async saveAttempt(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).user.id;
            const {
                question_id,
                is_correct,
                category_id,
                user_answer,
                time_taken_ms,
            } = req.body;

            const { data, error } = await supabase
                .from("quiz_attempts")
                .insert({
                    user_id: userId,
                    session_id: req.body.session_id, // Might be null if direct
                    question_id,
                    category_id,
                    is_correct,
                    user_answer,
                    time_taken_ms,
                } as any)

                .select("*")
                .single();

            if (error) throw error;
            return successResponse(res, data, "Attempt saved");
        } catch (error: any) {
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * POST /api/user-quiz/batch
     * Save multiple attempts (Sync)
     */
    async saveBatchAttempts(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).user?.id;
            if (!userId) {
                return errorResponse(res, "Authentication required", 401);
            }

            const { attempts } = req.body;
            if (!attempts || !Array.isArray(attempts)) {
                return errorResponse(res, "Invalid attempts format", 400);
            }

            const result = await quizUserService.saveBatchAttempts(
                userId,
                attempts,
            );
            return successResponse(res, result, "Batch attempts saved");
        } catch (error: any) {
            console.error("Batch Save Error:", error);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * GET /api/user-quiz/debug-db
     * Removed diagnostic route for security
     */
    async debugDb(req: Request, res: Response): Promise<void> {
        return successResponse(
            res,
            { status: "Cleaned" },
            "Debug route disabled",
        );
    }
}

export const quizUserController = new QuizUserController();
