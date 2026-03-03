import { Request, Response } from "express";
import { TreeGroupsService } from "./tree-groups.service";

export class TreeGroupsController {
    static async getAll(req: Request, res: Response) {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 100;

            const result = await TreeGroupsService.getAllGroups(page, limit);

            res.status(200).json({
                success: true,
                data: result.groups,
                meta: {
                    total: result.total,
                    page: result.page,
                    limit: result.limit,
                    totalPages: result.totalPages,
                },
            });
        } catch (error: any) {
            res.status(500).json({
                success: false,
                message: error.message || "Failed to fetch tree groups",
            });
        }
    }

    static async getOne(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const group = await TreeGroupsService.getGroupById(id);
            res.status(200).json({
                success: true,
                data: group,
            });
        } catch (error: any) {
            res.status(500).json({
                success: false,
                message: error.message || "Failed to fetch tree group",
            });
        }
    }

    static async create(req: Request, res: Response) {
        try {
            const data = req.body;
            const group = await TreeGroupsService.createGroup(data);
            res.status(201).json({
                success: true,
                data: group,
            });
        } catch (error: any) {
            res.status(500).json({
                success: false,
                message: error.message || "Failed to create tree group",
            });
        }
    }

    static async update(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const data = req.body;
            const group = await TreeGroupsService.updateGroup(id, data);
            res.status(200).json({
                success: true,
                data: group,
            });
        } catch (error: any) {
            res.status(500).json({
                success: false,
                message: error.message || "Failed to update tree group",
            });
        }
    }

    static async delete(req: Request, res: Response) {
        try {
            const { id } = req.params;
            await TreeGroupsService.deleteGroup(id);
            res.status(200).json({
                success: true,
                message: "Tree group deleted successfully",
            });
        } catch (error: any) {
            res.status(500).json({
                success: false,
                message: error.message || "Failed to delete tree group",
            });
        }
    }
}
