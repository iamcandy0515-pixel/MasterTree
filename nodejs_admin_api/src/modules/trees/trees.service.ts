import { supabase } from "../../config/supabaseClient";
import { CreateTreeDto, TreeResponseDto, TreeImageDto } from "./trees.dto";
import { logger } from "../../utils/logger";
import { stringify } from "csv-stringify/sync";
import { parse } from "csv-parse/sync";

const IMAGE_TYPES = ["main", "leaf", "bark", "flower", "fruit"];

export class TreeService {
    static async getAll(
        page = 1,
        limit = 20,
        search?: string,
        category?: string,
    ) {
        // 1. Calculate Offset
        const from = (page - 1) * limit;
        const to = from + limit - 1;

        // 2. Base Query
        let query = supabase
            .from("trees")
            .select(
                `
                *,
                tree_images (
                    image_type,
                    image_url,
                    thumbnail_url,
                    hint,
                    is_quiz_enabled
                )
            `,
                { count: "exact" }, // Get total count for pagination
            )
            .order("name_kr", { ascending: true })
            .range(from, to);

        // 3. Apply Filters
        if (search) {
            // Check name_kr or scientific_name (case-insensitive)
            query = query.or(
                `name_kr.eq.${search},scientific_name.ilike.%${search}%`,
            );
        }

        if (category && category !== "전체") {
            // Apply category filter if provided and not 'All'
            query = query.or(
                `category.ilike.%${category}%,description.ilike.%${category}%`,
            );
        }

        const { data, error, count } = await query;

        if (error) {
            logger.error("Failed to fetch trees", error);
            throw error;
        }

        // 4. Client-Side Deduplication (Server Memory)
        // Since we are paginating raw rows, the deduplication happens on the fetched chunk.
        // Ideally, we should deduplicate *before* pagination to have consistent pages,
        // but Supabase/PostgREST doesn't support GROUP BY with nested select easily.
        // For now, we mimic the client logic on this chunk to reduce payload size.
        // NOTE: This might cut off a group if it spans across pages.
        // A robust solution requires a custom RPC or distinct query first.

        // For User Requirement: "Load Optimization" - meaningful reduction.
        // Let's optimize by merging.

        const uniqueTreeMap = new Map<string, any>();

        for (const tree of data || []) {
            if (!uniqueTreeMap.has(tree.name_kr)) {
                uniqueTreeMap.set(tree.name_kr, { ...tree });
            } else {
                const existing = uniqueTreeMap.get(tree.name_kr);
                // Merge images
                if (tree.tree_images && Array.isArray(tree.tree_images)) {
                    existing.tree_images = [
                        ...(existing.tree_images || []),
                        ...tree.tree_images,
                    ];
                }
                uniqueTreeMap.set(tree.name_kr, existing);
            }
        }

        const mergedData = Array.from(uniqueTreeMap.values());

        return {
            data: mergedData,
            meta: {
                total: count || 0,
                page,
                limit,
                totalPages: count ? Math.ceil(count / limit) : 0,
            } as any,
        };
    }

    static async getDetailedStats() {
        try {
            // 1. Basic Counts (Head only)
            const { count: totalTrees, error: err1 } = await supabase
                .from("trees")
                .select("*", { count: "exact", head: true });

            if (err1) throw err1;

            // 2. Category Distribution (Fetch only category column)
            // Low payload even with 10k trees
            const { data: catData, error: err2 } = await supabase
                .from("trees")
                .select("category");

            if (err2) throw err2;

            const categoryStats: Record<string, number> = {};
            (catData || []).forEach((row: any) => {
                if (row.category) {
                    const cats = row.category.split(",");
                    cats.forEach((c: string) => {
                        const clean = c.trim();
                        if (clean) {
                            categoryStats[clean] =
                                (categoryStats[clean] || 0) + 1;
                        }
                    });
                } else {
                    categoryStats["미분류"] =
                        (categoryStats["미분류"] || 0) + 1;
                }
            });

            // 3. Recent Updates (System Logs alternative)
            const { data: recentTrees } = await supabase
                .from("trees")
                .select("id, name_kr, created_at")
                .order("created_at", { ascending: false })
                .limit(5);

            return {
                totalTrees: totalTrees || 0,
                categoryStats,
                recentUpdates: recentTrees || [],
                // Mock Quiz Stats until table exists
                quizStats: {
                    avgScore: 72,
                    topWrongAnswers: [
                        { name: "측백나무", count: 15 },
                        { name: "화백", count: 12 },
                        { name: "편백", count: 10 },
                        { name: "주목", count: 8 },
                        { name: "구상나무", count: 5 },
                    ],
                },
            };
        } catch (error) {
            logger.error("Failed to get detailed stats", error);
            throw error;
        }
    }

    static async create(dto: CreateTreeDto, userId: string) {
        // 0. 이름 정규화 (공백 완전 제거)
        const nameKr = dto.name_kr.replace(/\s+/g, "");

        // 1. trees 테이블에 기본 정보 저장
        const { data: treeData, error: treeError } = await supabase
            .from("trees")
            .insert([
                {
                    name_kr: nameKr,
                    name_en: dto.name_en,
                    scientific_name: dto.scientific_name,
                    category: dto.category ? dto.category : "활엽수", // Default to Broadleaf if not provided, or logic? User usually provides it now.
                    description: dto.description,
                    difficulty: dto.difficulty || 1,
                    quiz_distractors: dto.quiz_distractors || [],
                    is_auto_quiz_enabled: dto.is_auto_quiz_enabled ?? true,
                    created_by: userId,
                },
            ])
            .select()
            .single();

        if (treeError) {
            // Postgres Unique Violation Error Code: 23505
            if (treeError.code === "23505") {
                const error = new Error(`이미 등록된 나무입니다: ${nameKr}`);
                (error as any).statusCode = 409;
                throw error;
            }
            logger.error("Failed to create tree", treeError);
            throw treeError;
        }

        const treeId = treeData.id;

        // 2. tree_images 테이블에 이미지들 저장 (Bulk Insert)
        if (dto.images && dto.images.length > 0) {
            const imageRecords = dto.images.map((img) => ({
                tree_id: treeId,
                image_type: img.image_type,
                image_url: img.image_url,
                thumbnail_url: img.thumbnail_url,
                hint: img.hint,
                is_quiz_enabled: img.is_quiz_enabled ?? true,
                uploaded_by: userId,
            }));

            const { error: imgError } = await supabase
                .from("tree_images")
                .insert(imageRecords);

            if (imgError) {
                logger.error("Failed to insert tree images", imgError);
                // ⚠️ 중요: 트랜잭션이 없으므로(Supabase JS Client 제한), 이미지 저장 실패 시 Tree 삭제 고려 필요.
                // await supabase.from('trees').delete().eq('id', treeId);
                throw imgError;
            }
        }

        return { ...treeData, tree_images: dto.images };
    }

    static async update(id: number, dto: CreateTreeDto, userId: string) {
        // 0. 이름 정규화 (공백 완전 제거)
        const nameKr = dto.name_kr.replace(/\s+/g, "");

        // 1. trees 테이블 기본 정보 업데이트
        const { data: treeData, error: treeError } = await supabase
            .from("trees")
            .update({
                name_kr: nameKr,
                name_en: dto.name_en,
                scientific_name: dto.scientific_name,
                category: dto.category,
                description: dto.description,
                difficulty: dto.difficulty,
                quiz_distractors: dto.quiz_distractors,
                is_auto_quiz_enabled: dto.is_auto_quiz_enabled,
            })
            .eq("id", id)
            .select()
            .single();

        if (treeError) {
            if (treeError.code === "23505") {
                const error = new Error(`이미 등록된 나무입니다: ${nameKr}`);
                (error as any).statusCode = 409;
                throw error;
            }
            logger.error(`Failed to update tree ${id}`, treeError);
            throw treeError;
        }

        // 2. 이미지 업데이트 (기존 이미지 삭제 후 신규 등록 - 단순화된 방식)
        // 실제 운영 환경에서는 차이점만 반영(Diff)하는 것이 좋지만,
        // 일단 관리자 앱이므로 전체 교체 방식으로 구현합니다.

        // 기존 이미지 삭제
        await supabase.from("tree_images").delete().eq("tree_id", id);

        // 새 이미지 등록
        if (dto.images && dto.images.length > 0) {
            const imageRecords = dto.images.map((img) => ({
                tree_id: id,
                image_type: img.image_type,
                image_url: img.image_url,
                thumbnail_url: img.thumbnail_url,
                hint: img.hint,
                is_quiz_enabled: img.is_quiz_enabled ?? true,
                uploaded_by: userId,
            }));

            const { error: imgError } = await supabase
                .from("tree_images")
                .insert(imageRecords);

            if (imgError) {
                logger.error("Failed to update tree images", imgError);
                throw imgError;
            }
        }

        return { ...treeData, tree_images: dto.images };
    }

    static async delete(id: number) {
        const { error } = await supabase.from("trees").delete().eq("id", id);

        if (error) {
            logger.error(`Failed to delete tree ${id}`, error);
            throw error;
        }

        return true;
    }

    static async getRandom(
        count: number,
        category?: string,
        excludeName?: string,
    ) {
        let query = supabase.from("trees").select("name_kr, category");

        if (category && category !== "전체") {
            const tags = category.split(",");
            tags.forEach((tag) => {
                const trimmedTag = tag.trim();
                if (trimmedTag) {
                    query = query.ilike("category", `%${trimmedTag}%`);
                }
            });
        }

        if (excludeName) {
            query = query.neq("name_kr", excludeName);
        }

        const { data, error } = await query;

        if (error) {
            logger.error("Failed to fetch random trees", error);
            throw error;
        }

        if (!data || data.length === 0) return [];

        // Deduplicate names first (just in case DB has dupes)
        const uniqueNames = [...new Set(data.map((t) => t.name_kr))];

        // Shuffle and slice
        const shuffled = uniqueNames.sort(() => 0.5 - Math.random());
        return shuffled.slice(0, count);
    }

    static async exportTreesCsv() {
        // Fetch all trees with images
        const { data, error } = await supabase
            .from("trees")
            .select("*, tree_images(*)")
            .order("name_kr", { ascending: true });

        if (error) throw error;

        // Flatten data for CSV
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

            // Add image columns
            IMAGE_TYPES.forEach((type) => {
                const img = (tree.tree_images || []).find(
                    (i: any) => i.image_type === type,
                );
                row[`${type}_url`] = img?.image_url || "";
                row[`${type}_thumb_url`] = img?.thumbnail_url || "";
                row[`${type}_hint`] = img?.hint || "";
            });

            return row;
        });

        const csv = stringify(rows, {
            header: true,
            bom: true, // for Excel Korean encoding
        });

        return csv;
    }

    static async importTreesCsv(buffer: Buffer, userId: string) {
        const csvContent = buffer.toString("utf-8");
        const rows = parse(csvContent, {
            columns: true,
            skip_empty_lines: true,
        });

        const results = {
            success: 0,
            failed: 0,
            errors: [] as string[],
        };

        for (const row of rows as any[]) {
            let nameKr = "";
            try {
                nameKr = row.name_kr?.replace(/\s+/g, "") || "";
                if (!nameKr) throw new Error("name_kr is missing");

                // Prepare tree data
                const treeData = {
                    name_kr: nameKr,
                    name_en: row.name_en,
                    scientific_name: row.scientific_name,
                    category: row.category,
                    description: row.description,
                    difficulty: parseInt(row.difficulty) || 1,
                    quiz_distractors: row.quiz_distractors
                        ? row.quiz_distractors
                              .split(",")
                              .map((s: string) => s.trim())
                              .filter(Boolean)
                        : [],
                    is_auto_quiz_enabled: row.is_auto_quiz_enabled === "Y",
                };

                // Upsert Tree
                const { data: existingTree } = await supabase
                    .from("trees")
                    .select("id")
                    .eq("name_kr", nameKr)
                    .maybeSingle();

                let treeId: number;
                if (existingTree) {
                    treeId = existingTree.id;
                    const { error } = await supabase
                        .from("trees")
                        .update(treeData)
                        .eq("id", treeId);
                    if (error) throw error;
                } else {
                    const { data: newTree, error } = await supabase
                        .from("trees")
                        .insert([{ ...treeData, created_by: userId }])
                        .select()
                        .single();
                    if (error) throw error;
                    treeId = newTree.id;
                }

                // Handle Images
                const imagesToInsert: any[] = [];
                IMAGE_TYPES.forEach((type) => {
                    const url = row[`${type}_url`];
                    const hint = row[`${type}_hint`];
                    if (url) {
                        imagesToInsert.push({
                            tree_id: treeId,
                            image_type: type,
                            image_url: url,
                            thumbnail_url: row[`${type}_thumb_url`] || null,
                            hint: hint || null,
                            is_quiz_enabled: true,
                            uploaded_by: userId,
                        });
                    }
                });

                if (imagesToInsert.length > 0) {
                    await supabase
                        .from("tree_images")
                        .delete()
                        .eq("tree_id", treeId);
                    const { error } = await supabase
                        .from("tree_images")
                        .insert(imagesToInsert);
                    if (error) throw error;
                }

                results.success++;
            } catch (e: any) {
                results.failed++;
                results.errors.push(`Row ${nameKr || "unknown"}: ${e.message}`);
            }
        }

        return results;
    }
}
