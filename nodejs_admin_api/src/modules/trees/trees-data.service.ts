import { treeRepository } from "./trees.repository";
import { logger } from "../../utils/logger";
import { stringify } from "csv-stringify/sync";
import { parse } from "csv-parse/sync";
import { QUIZ_STATS_MOCK } from "./trees-stats.mock";

const IMAGE_TYPES = ["main", "leaf", "bark", "flower", "fruit"];

/**
 * Tree Data Service (Strategy C-1)
 * Optimized for Load Balancing by isolating heavy batch and aggregation logic.
 * Adheres to Rule 1-1 (200-line limit).
 */
export class TreeDataService {
    /**
     * Aggregates stats from DB and merges with mock data (Choice 2.A)
     */
    async getDetailedStats() {
        try {
            const { total, categories, recent } = await treeRepository.getGlobalStats();
            if (total.error) throw total.error;

            const categoryStats: Record<string, number> = {};
            (categories.data || []).forEach((row: any) => {
                if (row.category) {
                    row.category.split(",").forEach((c: string) => {
                        const clean = c.trim();
                        if (clean) categoryStats[clean] = (categoryStats[clean] || 0) + 1;
                    });
                } else {
                    categoryStats["미분류"] = (categoryStats["미분류"] || 0) + 1;
                }
            });

            return {
                totalTrees: total.count || 0,
                categoryStats,
                recentUpdates: recent.data || [],
                quizStats: QUIZ_STATS_MOCK,
            };
        } catch (error) {
            logger.error("[TreeData] Stats Aggregation Error:", error);
            throw error;
        }
    }

    /**
     * Flatten trees and images into CSV format for export
     */
    async exportTreesCsv() {
        const { data, error } = await treeRepository.findAllForExport();
        if (error) throw error;

        const rows = (data || []).map((tree) => {
            const row: any = {
                id: tree.id,
                name_kr: tree.name_kr,
                name_en: tree.name_en || "",
                scientific_name: tree.scientific_name || "",
                category: tree.category || "",
                description: tree.description || "",
                difficulty: tree.difficulty || 1,
                quiz_distractors: (tree.quiz_distractors || []).join(", "),
                is_auto_quiz_enabled: tree.is_auto_quiz_enabled ? "Y" : "N",
            };

            IMAGE_TYPES.forEach((type) => {
                const img = (tree.tree_images || []).find((i: any) => i.image_type === type);
                row[`${type}_url`] = img?.quizz_source_image_url || img?.image_url || "";
                row[`${type}_thumb_url`] = img?.thumbnail_url || "";
                row[`${type}_hint`] = img?.hint || "";
            });
            return row;
        });

        return stringify(rows, { header: true, bom: true });
    }

    /**
     * Batch upsert from CSV buffer (Choice 1.A: Delete-and-Insert for images)
     */
    async importTreesCsv(buffer: Buffer, userId: string) {
        const rows = parse(buffer.toString("utf-8"), { columns: true, skip_empty_lines: true });
        const results = { success: 0, failed: 0, errors: [] as string[] };

        for (const row of rows as any[]) {
            let nameKr = "";
            try {
                nameKr = row.name_kr?.replace(/\s+/g, "") || "";
                if (!nameKr) throw new Error("name_kr is missing");

                const treeData = this._mapCsvRowToTree(row);
                const { data: existing } = await treeRepository.findByNameKr(nameKr);

                let treeId: number;
                if (existing) {
                    treeId = existing.id;
                    const { error } = await treeRepository.updateTree(treeId, treeData);
                    if (error) throw error;
                } else {
                    const { data: newTree, error } = await treeRepository.insertTree({ ...treeData, created_by: userId });
                    if (error) throw error;
                    treeId = newTree.id;
                }

                await this._handleCsvImages(treeId, row, userId);
                results.success++;
            } catch (e: any) {
                results.failed++;
                results.errors.push(`Row ${nameKr || "unknown"}: ${e.message}`);
            }
        }
        return results;
    }

    // --- Private Helpers ---

    private _mapCsvRowToTree(row: any) {
        return {
            name_kr: row.name_kr?.replace(/\s+/g, ""),
            name_en: row.name_en,
            scientific_name: row.scientific_name,
            category: row.category,
            description: row.description,
            difficulty: parseInt(row.difficulty) || 1,
            quiz_distractors: row.quiz_distractors ? row.quiz_distractors.split(",").map((s: string) => s.trim()).filter(Boolean) : [],
            is_auto_quiz_enabled: row.is_auto_quiz_enabled === "Y",
        };
    }

    private async _handleCsvImages(treeId: number, row: any, userId: string) {
        const images: any[] = [];
        IMAGE_TYPES.forEach((type) => {
            const url = row[`${type}_url`];
            if (url) {
                images.push({
                    tree_id: treeId,
                    image_type: type,
                    image_url: url,
                    thumbnail_url: row[`${type}_thumb_url`] || null,
                    hint: row[`${type}_hint`] || null,
                    is_quiz_enabled: true,
                    uploaded_by: userId,
                });
            }
        });

        if (images.length > 0) {
            await treeRepository.deleteImagesByTreeId(treeId); // Choice 1.A
            const { error } = await treeRepository.insertImages(images);
            if (error) throw error;
        }
    }
}

export const treeDataService = new TreeDataService();
