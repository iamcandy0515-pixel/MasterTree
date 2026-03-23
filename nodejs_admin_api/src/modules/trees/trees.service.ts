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
     * Retrieves trees with pagination and in-memory deduplication/merging
     */
    static async getAll(page = 1, limit = 20, search?: string, category?: string) {
        const offset = (page - 1) * limit;
        const { data, error, count } = await treeRepository.findAll(offset, limit, search, category);

        if (error) {
            logger.error("[TreeService] Failed to fetch trees:", error);
            throw error;
        }

        // Deduplication/Merging logic (Rule 3 Optimization)
        const uniqueTreeMap = new Map<string, any>();
        for (const tree of data || []) {
            if (!uniqueTreeMap.has(tree.name_kr)) {
                uniqueTreeMap.set(tree.name_kr, { ...tree });
            } else {
                const existing = uniqueTreeMap.get(tree.name_kr);
                if (tree.tree_images && Array.isArray(tree.tree_images)) {
                    existing.tree_images = [...(existing.tree_images || []), ...tree.tree_images];
                }
                uniqueTreeMap.set(tree.name_kr, existing);
            }
        }

        return {
            data: Array.from(uniqueTreeMap.values()),
            meta: { total: count || 0, page, limit, totalPages: count ? Math.ceil(count / limit) : 0 },
        };
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

        const treeId = treeData.id;
        if (dto.images && dto.images.length > 0) {
            const imageRecords = dto.images.map(img => ({ ...img, tree_id: treeId, uploaded_by: userId }));
            const { error: imgError } = await treeRepository.insertImages(imageRecords);
            if (imgError) logger.error("[TreeService] Image insert failed for tree", treeId, imgError);
        }

        return { ...treeData, tree_images: dto.images };
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

        await treeRepository.deleteImagesByTreeId(id); // Choice 1.A
        if (dto.images && dto.images.length > 0) {
            const imageRecords = dto.images.map(img => ({ ...img, tree_id: id, uploaded_by: userId }));
            await treeRepository.insertImages(imageRecords);
        }

        return { ...treeData, tree_images: dto.images };
    }

    /**
     * Deletes a tree and its images automatically (via DB cascade or explicit call)
     */
    static async delete(id: number) {
        const { error } = await treeRepository.deleteTree(id);
        if (error) {
            logger.error(`[TreeService] Failed to delete tree ${id}:`, error);
            throw error;
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

    private static _mapDtoToTree(dto: CreateTreeDto, nameKr: string, userId: string) {
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
