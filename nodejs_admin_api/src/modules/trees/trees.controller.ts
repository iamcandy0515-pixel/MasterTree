import { Request, Response } from "express";
import { TreeService } from "./trees.service";
import { CreateTreeDto } from "./trees.dto";
import { successResponse, errorResponse } from "../../utils/response";

export class TreeController {
    static async getAll(req: Request, res: Response) {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 20;
            const search = req.query.search as string;
            const category = req.query.category as string;

            const result = await TreeService.getAll(
                page,
                limit,
                search,
                category,
            );

            // Return standard response with meta
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

    static async getStats(req: Request, res: Response) {
        try {
            const stats = await TreeService.getDetailedStats();
            successResponse(
                res,
                stats,
                "Detailed stats retrieved successfully",
            );
        } catch (error: any) {
            errorResponse(
                res,
                error.message || "Failed to retrieve stats",
                500,
            );
        }
    }

    static async create(req: Request, res: Response) {
        try {
            // Validate minimal requirement
            const dto: CreateTreeDto = req.body;
            if (!dto.name_kr) {
                return errorResponse(res, "Tree name_kr is required", 400);
            }
            if (!dto.images || !Array.isArray(dto.images)) {
                return errorResponse(res, "Images array is required", 400);
            }

            // Extract User ID from Auth Middleware (Assuming verifyAdmin adds user to req)
            // Note: Express Request type needs extension or use 'as any' for now
            const userId = (req as any).user?.id;

            if (!userId) {
                // Should be caught by verifyAdmin, but double check
                return errorResponse(res, "Unauthorized: User ID missing", 401);
            }

            const newTree = await TreeService.create(dto, userId);
            successResponse(res, newTree, "Tree created successfully", 201);
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to create tree", 500);
        }
    }

    static async update(req: Request, res: Response) {
        try {
            const id = parseInt(req.params.id);
            if (isNaN(id)) {
                return errorResponse(res, "Invalid tree ID", 400);
            }

            const dto: CreateTreeDto = req.body;
            if (!dto.name_kr) {
                return errorResponse(res, "Tree name_kr is required", 400);
            }

            const userId = (req as any).user?.id;
            if (!userId) {
                return errorResponse(res, "Unauthorized: User ID missing", 401);
            }

            const updatedTree = await TreeService.update(id, dto, userId);
            successResponse(res, updatedTree, "Tree updated successfully");
        } catch (error: any) {
            const status = error.statusCode || 500;
            errorResponse(
                res,
                error.message || "Failed to update tree",
                status,
            );
        }
    }

    static async delete(req: Request, res: Response) {
        try {
            const id = parseInt(req.params.id);
            if (isNaN(id)) {
                return errorResponse(res, "Invalid tree ID", 400);
            }

            await TreeService.delete(id);
            successResponse(res, { id }, "Tree deleted successfully");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to delete tree", 500);
        }
    }

    static async getRandom(req: Request, res: Response) {
        try {
            const count = parseInt(req.query.count as string) || 3;
            const category = req.query.category as string;
            const excludeName = req.query.excludeName as string;

            const names = await TreeService.getRandom(
                count,
                category,
                excludeName,
            );
            successResponse(res, names, "Random trees retrieved successfully");
        } catch (error: any) {
            errorResponse(
                res,
                error.message || "Failed to retrieve random trees",
                500,
            );
        }
    }

    static async exportCsv(req: Request, res: Response) {
        try {
            const csv = await TreeService.exportTreesCsv();
            res.header("Content-Type", "text/csv; charset=utf-8");
            res.attachment(`trees_export_${new Date().getTime()}.csv`);
            return res.send(csv);
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to export trees");
        }
    }

    static async importCsv(req: Request, res: Response) {
        try {
            if (!req.file) {
                return errorResponse(res, "No file uploaded", 400);
            }

            const userId = (req as any).user?.id;
            const results = await TreeService.importTreesCsv(
                req.file.buffer,
                userId,
            );

            successResponse(res, results, "Import processed");
        } catch (error: any) {
            errorResponse(res, error.message || "Failed to import trees");
        }
    }
}
