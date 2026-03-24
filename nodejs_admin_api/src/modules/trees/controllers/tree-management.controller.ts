import { Request, Response } from "express";
import { TreeService } from "../trees.service";
import { CreateTreeDto } from "../trees.dto";
import { successResponse, errorResponse } from "../../../utils/response";

/**
 * Tree Management Controller
 * Handles core CRUD operations forTrees.
 * Optimized for mobile payloads.
 */
export class TreeManagementController {
    /**
     * getAll: Paginated tree list (Field Pruning available via minimal=true)
     */
    static async getAll(req: Request, res: Response) {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 20;
            const search = req.query.search as string;
            const category = req.query.category as string;
            const minimal = req.query.minimal === "true";

            const result = await TreeService.getAll(page, limit, search, category, minimal);

            successResponse(res, result.data, "Trees retrieved successfully", 200, result.meta);
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to retrieve trees");
        }
    }

    /**
     * create: Protected CRUD
     */
    static async create(req: Request, res: Response) {
        try {
            const dto: CreateTreeDto = req.body;
            if (!dto.name_kr) return errorResponse(res, "Tree name_kr is required", 400);

            const userId = (req as any).user?.id || "system";
            const newTree = await TreeService.create(dto, userId);
            successResponse(res, newTree, "Tree created successfully", 201);
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to create tree", 500);
        }
    }

    /**
     * update: Protected CRUD
     */
    static async update(req: Request, res: Response) {
        try {
            const id = parseInt(req.params.id);
            const dto: CreateTreeDto = req.body;
            if (isNaN(id) || !dto.name_kr) return errorResponse(res, "Invalid request", 400);

            const userId = (req as any).user?.id || "system";
            const updatedTree = await TreeService.update(id, dto, userId);
            successResponse(res, updatedTree, "Tree updated successfully");
        } catch (error: any) {
            const status = (error as any).statusCode || 500;
            errorResponse(res, error.message || "Failed to update tree", status);
        }
    }

    /**
     * delete: Protected CRUD
     */
    static async delete(req: Request, res: Response) {
        try {
            const id = parseInt(req.params.id);
            if (isNaN(id)) return errorResponse(res, "Invalid tree ID", 400);

            await TreeService.delete(id);
            successResponse(res, { id }, "Tree deleted successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to delete tree", 500);
        }
    }
}
