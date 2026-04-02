import { Request, Response } from "express";
import { usersService } from "../users.service";
import { successResponse, errorResponse } from "../../../utils/response";

/**
 * User Management Controller
 * Handles administrative actions like listing, updating status, and deleting users.
 */
export class UserManagementController {
    /**
     * listUsers: Paginated list with mobile optimization support
     */
    static async listUsers(req: Request, res: Response) {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 50;
            const status = req.query.status as string;
            const minimal = req.query.minimal === "true"; // Add support for minimal mode

            // Forward minimal to service
            const result = await usersService.listUsers(page, limit, status, minimal);

            // Extract meta for standardized meta field
            const meta = (result as any).meta || null;
            const data = (result as any).data || result;

            return successResponse(res, { users: data }, "Users retrieved successfully", 200, meta);
        } catch (error: any) {
            console.error("[UserManagement] List Error:", error.message);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * updateUserStatus: Administrative status control
     */
    static async updateUserStatus(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { status } = req.body;
            if (!id || !status) return errorResponse(res, "ID and status are required", 400);

            const result = await usersService.updateUserStatus(id, status);
            return successResponse(res, result, "User status updated successfully");
        } catch (error: any) {
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * deleteUser: Permanent deletion
     */
    static async deleteUser(req: Request, res: Response) {
        try {
            const { id } = req.params;
            if (!id) return errorResponse(res, "User ID is required", 400);

            await usersService.deleteUser(id);
            return successResponse(res, null, "User deleted successfully");
        } catch (error: any) {
            return errorResponse(res, error.message, 500);
        }
    }
}
