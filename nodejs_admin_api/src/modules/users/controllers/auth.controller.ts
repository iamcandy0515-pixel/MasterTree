import { Request, Response } from "express";
import { usersService } from "../users.service";
import { successResponse, errorResponse } from "../../../utils/response";
import { logger } from "../../../utils/logger";

/**
 * Auth Controller
 * Handles user authentication, token management, and profile retrieval.
 */
export class AuthController {
    /**
     * login: Entry point for authentication
     */
    static async login(req: Request, res: Response) {
        try {
            const { email, password } = req.body;
            if (!email || !password) return errorResponse(res, "Email and password are required", 400);

            const result = await usersService.login({ email, password });
            logger.info(`User logged in: ${email}`);
            return successResponse(res, result, "Login successful");
        } catch (error: any) {
            logger.error("Login error", error.message);
            return errorResponse(res, error.message, 401);
        }
    }

    /**
     * getMe: Protected route to get own profile
     */
    static async getMe(req: Request, res: Response) {
        try {
            // req.user is populated by verifyAdmin or general auth middleware
            return successResponse(
                res,
                { user: (req as any).user },
                "User profile retrieved",
            );
        } catch (error: any) {
            return errorResponse(res, error.message, 500);
        }
    }
}
