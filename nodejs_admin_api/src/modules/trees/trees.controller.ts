import { Request, Response } from "express";
import { TreeService } from "./trees.service";
import { treeDataService } from "./trees-data.service";
import { CreateTreeDto } from "./trees.dto";
import { successResponse, errorResponse } from "../../utils/response";

/**
 * Tree Controller
 * Handles HTTP requests for the Trees module.
 * Optimized to call specialized services directly (Choice 3.B).
 */
export class TreeController {
    /**
     * listAll: Paginated tree list (Orchestrated by TreeService)
     */
    static async getAll(req: Request, res: Response) {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 20;
            const search = req.query.search as string;
            const category = req.query.category as string;

            const result = await TreeService.getAll(page, limit, search, category);

            res.status(200).json({
                success: true,
                message: "Trees retrieved successfully",
                data: result.data,
                meta: result.meta,
            });
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to retrieve trees");
        }
    }

    /**
     * getStats: Detailed aggregation (Handled by TreeDataService)
     */
    static async getStats(req: Request, res: Response) {
        try {
            const stats = await treeDataService.getDetailedStats();
            successResponse(res, stats, "Detailed stats retrieved successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to retrieve stats", 500);
        }
    }

    /**
     * create: Direct TreeService call for CRUD
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
     * update: Direct TreeService call for CRUD
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
     * delete: Simple delete orchestration
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

    /**
     * getRandom: Logic within TreeService
     */
    static async getRandom(req: Request, res: Response) {
        try {
            const count = parseInt(req.query.count as string) || 3;
            const category = req.query.category as string;
            const excludeName = req.query.excludeName as string;

            const names = await TreeService.getRandom(count, category, excludeName);
            successResponse(res, names, "Random trees retrieved successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to retrieve random trees", 500);
        }
    }

    /**
     * exportCsv: Handled by TreeDataService
     */
    static async exportCsv(req: Request, res: Response) {
        try {
            const csv = await treeDataService.exportTreesCsv();
            res.header("Content-Type", "text/csv; charset=utf-8");
            res.attachment(`trees_export_${Date.now()}.csv`);
            return res.send(csv);
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to export trees");
        }
    }

    /**
     * importCsv: Handled by TreeDataService
     */
    static async importCsv(req: Request, res: Response) {
        try {
            if (!req.file) return errorResponse(res, "No file uploaded", 400);

            const userId = (req as any).user?.id || "system";
            const results = await treeDataService.importTreesCsv(req.file.buffer, userId);

            successResponse(res, results, "Import processed");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to import trees");
        }
    }
}
