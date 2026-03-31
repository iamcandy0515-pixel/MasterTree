import { supabase } from "../../config/supabaseClient";

/**
 * Tree Repository
 * Handles all direct database interactions for the Trees module.
 * Following Rule 1-1 of DEVELOPMENT_RULES.md (200-line limit).
 */
export class TreeRepository {
    /**
     * Fetches trees with optional associated images using pagination and filters
     */
    async findAll(offset: number, limit: number, search?: string, category?: string, withImages = false) {
        let queryStr = `
            id, 
            name_kr, 
            name_en, 
            scientific_name, 
            description, 
            category, 
            difficulty, 
            shape, 
            quiz_distractors, 
            is_auto_quiz_enabled, 
            created_at, 
            created_by
        `;

        if (withImages) {
            queryStr += `,
                tree_images (
                    id,
                    image_type,
                    image_url,
                    thumbnail_url,
                    hint,
                    is_quiz_enabled
                )
            `;
        }

        let query = supabase
            .from("trees")
            .select(queryStr, { count: "exact" })
            .order("name_kr", { ascending: true })
            .range(offset, offset + limit - 1);

        if (search) {
            query = query.or(`name_kr.ilike.%${search}%,scientific_name.ilike.%${search}%`);
        }
        if (category && category !== "전체") {
            query = query.or(`category.ilike.%${category}%,description.ilike.%${category}%`);
        }

        return await query;
    }

    /**
     * Fetches a specific tree with all images and hints for detail/preview
     */
    async findById(id: number) {
        return await supabase
            .from("trees")
            .select(`
                *,
                tree_images (
                    id,
                    image_type,
                    image_url,
                    thumbnail_url,
                    hint,
                    is_quiz_enabled,
                    created_at
                )
            `)
            .eq("id", id)
            .single();
    }

    /**
     * Fetches high-level stats (counts and category info)
     */
    async getGlobalStats() {
        const total = await supabase.from("trees").select("*", { count: "exact", head: true });
        const categories = await supabase.from("trees").select("category");
        const recent = await supabase
            .from("trees")
            .select("id, name_kr, created_at")
            .order("created_at", { ascending: false })
            .limit(5);

        return { total, categories, recent };
    }

    /**
     * Finds a tree by Korean name (exact match)
     */
    async findByNameKr(nameKr: string) {
        return await supabase.from("trees").select("id").eq("name_kr", nameKr).maybeSingle();
    }

    /**
     * Inserts a new tree record
     */
    async insertTree(payload: any) {
        return await supabase.from("trees").insert([payload]).select().single();
    }

    /**
     * Updates an existing tree record
     */
    async updateTree(id: number, payload: any) {
        return await supabase.from("trees").update(payload).eq("id", id).select().single();
    }

    /**
     * Deletes a tree record
     */
    async deleteTree(id: number) {
        return await supabase.from("trees").delete().eq("id", id);
    }

    /**
     * Fetches random tree names by category filter
     */
    async findRandomNames(category?: string, excludeName?: string) {
        let query = supabase.from("trees").select("name_kr, category");
        if (category && category !== "전체") {
            category.split(",").forEach(tag => {
                const trimmed = tag.trim();
                if (trimmed) query = query.ilike("category", `%${trimmed}%`);
            });
        }
        if (excludeName) query = query.neq("name_kr", excludeName);

        return await query;
    }

    /**
     * Inserts multiple tree images in bulk
     */
    async insertImages(records: any[]) {
        return await supabase.from("tree_images").insert(records);
    }

    /**
     * Deletes all images associated with a tree ID
     */
    async deleteImagesByTreeId(treeId: number) {
        return await supabase.from("tree_images").delete().eq("tree_id", treeId);
    }

    /**
     * Fetches all trees with images for CSV Export
     */
    async findAllForExport() {
        return await supabase
            .from("trees")
            .select("*, tree_images(*)")
            .order("name_kr", { ascending: true });
    }
}

export const treeRepository = new TreeRepository();
