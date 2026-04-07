import { Request, Response } from "express";
import { successResponse, errorResponse } from "../../utils/response";
import { supabase } from "../../config/supabaseClient";
import { statsAdminService } from "./services/stats_admin.service";
import { statsUserService } from "./services/stats_user.service";

export class StatsController {
    async getDashboardStats(req: Request, res: Response) {
        console.log("[Stats] getDashboardStats started");
        try {
            const [treesRes, quizRes, groupsRes] = await Promise.all([
                supabase.from("trees").select("*", { count: "exact", head: true }),
                supabase.from("quiz_questions").select("*", { count: "exact", head: true }),
                supabase.from("tree_groups").select("*", { count: "exact", head: true })
            ]);

            const totalTrees = treesRes.count || 0;
            const totalQuizzes = quizRes.count || 0;
            const totalGroups = groupsRes.count || 0;
            const activeUsers = 0; // Temporarily disabled for performance check

            console.log("[Stats] getDashboardStats success:", { totalTrees, totalQuizzes, totalGroups, activeUsers });
            return successResponse(res, {
                totalTrees,
                totalQuizzes,
                totalSimilarGroups: totalGroups,
                activeUsers,
            }, "Dashboard stats retrieved");
        } catch (error) {
            console.error("Dashboard Stats Error:", error);
            return errorResponse(res, "Failed to fetch dashboard stats", 500);
        }
    }

    async getAdminDetailedStats(req: Request, res: Response) {
        try {
            const data = await statsAdminService.getAdminDetailedStats();
            return successResponse(res, data, "Admin detailed stats retrieved");
        } catch (error) {
            console.error("Admin Detailed Stats Error:", error);
            return errorResponse(res, "Failed to fetch detailed stats", 500);
        }
    }

    async getUserPerformanceStats(req: Request, res: Response) {
        try {
            const userId = req.params.userId || (req.query.user_id as string) || (req as any).user?.id;
            if (!userId) return errorResponse(res, "User ID is required", 400);

            const data = await statsUserService.getUserPerformanceStats(userId);
            return successResponse(res, data, "User performance stats retrieved");
        } catch (error: any) {
            console.error("User Performance Stats Error:", error.message);
            return errorResponse(res, error.message, 500);
        }
    }

    async getUserDashboardStats(req: Request, res: Response) {
        try {
            const { count: totalTrees } = await (supabase as any).from("trees").select("*", { count: "exact", head: true });
            const { count: totalQuizzes } = await (supabase as any).from("quiz_questions").select("*", { count: "exact", head: true });
            const { count: totalGroups } = await (supabase as any).from("tree_groups").select("*", { count: "exact", head: true });

            return successResponse(res, {
                totalTrees: totalTrees || 0,
                totalQuizzes: totalQuizzes || 0,
                totalSimilarGroups: totalGroups || 0,
            }, "User dashboard stats retrieved");
        } catch (error) {
            console.error("User Stats Error:", error);
            return errorResponse(res, "Failed to fetch user stats", 500);
        }
    }

    async getTreeCategoryStats(req: Request, res: Response) {
        try {
            const userId = req.params.userId || (req.query.user_id as string) || (req as any).user?.id;
            if (!userId) return errorResponse(res, "User ID is required", 400);

            const data = await statsUserService.getTreeCategoryStats(userId);
            return successResponse(res, data, "Tree category stats retrieved");
        } catch (error: any) {
            console.error("Tree Category Stats Error:", error.message);
            return errorResponse(res, error.message, 500);
        }
    }

    async getExamSessionStats(req: Request, res: Response) {
        try {
            const userId = req.params.userId || (req.query.user_id as string) || (req as any).user?.id;
            if (!userId) return errorResponse(res, "User ID is required", 400);

            const data = await statsUserService.getExamSessionStats(userId);
            return successResponse(res, data, "Exam session stats retrieved");
        } catch (error: any) {
            console.error("Exam Session Stats Error:", error.message);
            return errorResponse(res, error.message, 500);
        }
    }
}

export const statsController = new StatsController();
