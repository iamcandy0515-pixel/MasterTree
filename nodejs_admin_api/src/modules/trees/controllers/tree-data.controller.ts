import { Request, Response } from "express";
import { TreeService } from "../trees.service";
import { treeDataService } from "../trees-data.service";
import { successResponse, errorResponse } from "../../../utils/response";

/**
 * Tree Data Controller
 * Handles statistics, CSV exports/imports, and randomization.
 */
export class TreeDataController {
    /**
     * getStats: Detailed aggregation
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
     * exportCsv: Data I/O
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
     * importCsv: Data I/O
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
