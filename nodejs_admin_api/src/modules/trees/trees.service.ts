import { treeRepository } from "./trees.repository";
import { CreateTreeDto } from "./trees.dto";
import { logger } from "../../utils/logger";

/**
 * Tree Service (Strategy C-2)
 * Core business orchestrator for Tree CRUD and Random selection.
 * Adheres to Rule 1-1 (200-line limit).
 */
export class TreeService {
    /**
     * Retrieves trees with pagination and lazy-loaded images (minimal mode)
     */
    static async getAll(page = 1, limit = 20, search?: string, category?: string, minimal = true) {
        const offset = (page - 1) * limit;
        
        // Minimal is true by default for list performance (Rule: No images in list)
        const { data, error, count } = await treeRepository.findAll(offset, limit, search, category, !minimal);

        if (error) {
            logger.error("[TreeService] Failed to fetch trees:", error);
            throw error;
        }

        const processedData = (data as any[]) || [];
        
        // Mapping for UI consistency (if needed)
        const result = processedData.map(tree => ({
            ...tree,
            // Add a placeholder if images are missing but UI expects it
            tree_images: tree.tree_images || []
        }));

        return {
            data: result,
            meta: { 
                total: count || 0, 
                page, 
                limit, 
                totalPages: count ? Math.ceil(count / limit) : 0 
            },
        };
    }

    /**
     * Retrieves a single tree with all images and hints for detail/preview
     */
    static async getOne(id: number) {
        const { data, error } = await treeRepository.findById(id);
        if (error) {
            logger.error(`[TreeService] Failed to fetch tree ${id}:`, error);
            throw error;
        }
        if (!data) {
            const err = new Error("해당 수목을 찾을 수 없습니다.");
            (err as any).statusCode = 404;
            throw err;
        }
        return data;
    }

    /**
     * Creates a new tree and its associated images
     */
    static async create(dto: CreateTreeDto, userId: string) {
        const nameKr = dto.name_kr.replace(/\s+/g, "");
        const payload = this._mapDtoToTree(dto, nameKr, userId);

        const { data: treeData, error: treeError } = await treeRepository.insertTree(payload);
        if (treeError) {
            if (treeError.code === "23505") throw this._createConflictError(nameKr);
            throw treeError;
        }

        const treeId = (treeData as any).id;
        if (dto.images && dto.images.length > 0) {
            const imageRecords = dto.images.map(img => ({ ...img, tree_id: treeId, uploaded_by: userId }));
            const { error: imgError } = await treeRepository.insertImages(imageRecords);
            if (imgError) logger.error(`[TreeService] Image insert failed for tree ${treeId}`, imgError);
        }

        return { ...(treeData as any), tree_images: dto.images };
    }

    /**
     * Updates a tree and replaces its images (Choice 1.A)
     */
    static async update(id: number, dto: CreateTreeDto, userId: string) {
        const nameKr = dto.name_kr.replace(/\s+/g, "");
        const payload = this._mapDtoToTree(dto, nameKr, userId);

        const { data: treeData, error: treeError } = await treeRepository.updateTree(id, payload);
        if (treeError) {
            if (treeError.code === "23505") throw this._createConflictError(nameKr);
            throw treeError;
        }

        // Choice 1.A: Re-sync images by delete-and-insert
        // [Refinement] Fetch existing image public_ids for Cloudinary cleanup before DB deletion
        const { data: oldImages } = await treeRepository.findImagesByTreeId(id);
        const { error: deleteError } = await treeRepository.deleteImagesByTreeId(id);
        if (deleteError) throw deleteError;

        // Cloudinary Cleanup (Async, Non-blocking for UI)
        if (oldImages && (oldImages as any[]).length > 0) {
            const publicIds = (oldImages as any[]).map(img => img.image_url).filter(url => url?.includes("cloudinary"));
            // Extract public_id from URL if stored as URL
            const extractedIds = publicIds.map(url => url.match(/(tree-images\/trees\/[^?./]+)/)?.[1]).filter(Boolean) as string[];
            if (extractedIds.length > 0) {
                const { UploadService } = require("../uploads/uploads.service");
                UploadService.deleteFromStorage(extractedIds).catch((e: any) => logger.warn(`[Cleanup] Update cleanup failed for tree ${id}:`, e));
            }
        }

        if (dto.images && dto.images.length > 0) {
            const imageRecords = dto.images.map(img => ({ ...img, tree_id: id, uploaded_by: userId }));
            const { error: insertError } = await treeRepository.insertImages(imageRecords);
            if (insertError) throw insertError;
        }

        return { ...treeData, tree_images: dto.images };
    }

    /**
     * Deletes a tree and its images automatically (via DB cascade and explicit Cloudinary call)
     */
    static async delete(id: number) {
        // [Refinement] Fetch images for Cloudinary cleanup before deletion
        const { data: images } = await treeRepository.findImagesByTreeId(id);
        
        const { error } = await treeRepository.deleteTree(id);
        if (error) {
            logger.error(`[TreeService] Failed to delete tree ${id}:`, error);
            throw error;
        }

        // Cloudinary Cleanup (Async)
        if (images && (images as any[]).length > 0) {
            const publicIds = (images as any[]).map(img => img.image_url).filter(url => url?.includes("cloudinary"));
            const extractedIds = publicIds.map(url => url.match(/(tree-images\/trees\/[^?./]+)/)?.[1]).filter(Boolean) as string[];
            if (extractedIds.length > 0) {
                const { UploadService } = require("../uploads/uploads.service");
                UploadService.deleteFromStorage(extractedIds).catch((e: any) => logger.warn(`[Cleanup] Delete cleanup failed for tree ${id}:`, e));
            }
        }

        return true;
    }

    /**
     * Retrieves random tree names for quiz distractors
     */
    static async getRandom(count: number, category?: string, excludeName?: string) {
        const { data, error } = await treeRepository.findRandomNames(category, excludeName);
        if (error) throw error;
        if (!data || data.length === 0) return [];

        const uniqueNames = [...new Set(data.map((t: any) => t.name_kr))];
        return uniqueNames.sort(() => 0.5 - Math.random()).slice(0, count);
    }

    // --- Private Helpers ---

    private static _mapDtoToTree(dto: CreateTreeDto, nameKr: string, userId: string): any {

        return {
            name_kr: nameKr,
            name_en: dto.name_en,
            scientific_name: dto.scientific_name,
            category: dto.category || "활엽수",
            description: dto.description,
            difficulty: dto.difficulty || 1,
            quiz_distractors: dto.quiz_distractors || [],
            is_auto_quiz_enabled: dto.is_auto_quiz_enabled ?? true,
            created_by: userId,
        };
    }

    private static _createConflictError(name: string) {
        const error = new Error(`이미 등록된 나무입니다: ${name}`);
        (error as any).statusCode = 409;
        return error;
    }
}
