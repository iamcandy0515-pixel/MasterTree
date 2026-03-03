import { Request, Response } from "express";
import { usersService } from "./users.service";
import { successResponse, errorResponse } from "../../utils/response";
import { logger } from "../../utils/logger";

export class UsersController {
    // POST /api/users/login
    async login(req: Request, res: Response) {
        try {
            const { email, password } = req.body;
            const result = await usersService.login({ email, password });

            logger.info(`User logged in: ${email}`);
            return successResponse(res, result, "Login successful");
        } catch (error: any) {
            logger.error("Login error", error.message);
            return errorResponse(res, error.message, 401);
        }
    }

    // GET /api/users/me (Optional: Protected route example)
    async getMe(req: Request, res: Response) {
        try {
            // req.user is populated by verifyAdmin middleware if used
            // For now, simple response
            return successResponse(
                res,
                { user: (req as any).user },
                "User profile retrieved",
            );
        } catch (error: any) {
            return errorResponse(res, error.message, 500);
        }
    }

    // GET /api/users
    async listUsers(req: Request, res: Response) {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 50;

            const result = await usersService.listUsers(page, limit);
            return successResponse(res, result, "Users retrieved successfully");
        } catch (error: any) {
            return errorResponse(res, error.message, 500);
        }
    }
}

export const usersController = new UsersController();
