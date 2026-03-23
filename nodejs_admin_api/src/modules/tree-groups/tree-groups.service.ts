import { supabase } from "../../config/supabaseClient";

export class TreeGroupsService {
    static async getAllGroups(page: number = 1, limit: number = 100) {
        const from = (page - 1) * limit;
        const to = from + limit - 1;

        // Fetch counts for pagination
        const { count, error: countError } = await supabase
            .from("tree_groups")
            .select("*", { count: "exact", head: true });

        if (countError) throw countError;

        // Fetch paginated data with essential fields only for the list
        const { data, error } = await supabase
            .from("tree_groups")
            .select(
                `
                id,
                group_name,
                description,
                created_at,
                tree_group_members (
                    *,
                    trees (
                        id,
                        name_kr,
                        tree_images (
                            image_type,
                            image_url,
                            hint
                        )
                    )
                )
            `,
            )
            .order("created_at", { ascending: false })
            .range(from, to);

        if (error) throw error;

        return {
            groups: data,
            total: count || 0,
            page,
            limit,
            totalPages: Math.ceil((count || 0) / limit),
        };
    }

    static async getGroupById(id: string) {
        const { data, error } = await supabase
            .from("tree_groups")
            .select(
                `
                *,
                tree_group_members (
                    *,
                    trees (
                        *,
                        tree_images (*)
                    )
                )
            `,
            )
            .eq("id", parseInt(id))
            .single();

        if (error) throw error;
        return data;
    }

    static async createGroup(data: any) {
        const { name, description, members } = data;
        const groupName = name || data.group_name;

        // 1. Create Group
        const { data: group, error: groupError } = await supabase
            .from("tree_groups")
            .insert({ group_name: groupName, description })
            .select()
            .single();

        if (groupError) throw groupError;

        // 2. Add Members
        if (members && members.length > 0) {
            const membersData = members.map((m: any, index: number) => ({
                group_id: group.id,
                tree_id: m.treeId || m.tree_id,
                sort_order: index,
                key_characteristics:
                    m.keyCharacteristics || m.key_characteristics,
            }));

            const { error: membersError } = await supabase
                .from("tree_group_members")
                .insert(membersData);

            if (membersError) throw membersError;
        }

        return group;
    }

    static async updateGroup(id: string, data: any) {
        const { name, description, members } = data;
        const groupName = name || data.group_name;

        // 1. Update Group
        const { error: groupError } = await supabase
            .from("tree_groups")
            .update({ group_name: groupName, description })
            .eq("id", parseInt(id));

        if (groupError) throw groupError;

        // 2. Delete existing members
        const { error: deleteError } = await supabase
            .from("tree_group_members")
            .delete()
            .eq("group_id", parseInt(id));

        if (deleteError) throw deleteError;

        // 3. Insert new members
        if (members && members.length > 0) {
            const membersData = members.map((m: any, index: number) => ({
                group_id: id,
                tree_id: m.treeId || m.tree_id,
                sort_order: index,
                key_characteristics:
                    m.keyCharacteristics || m.key_characteristics,
            }));

            const { error: insertError } = await supabase
                .from("tree_group_members")
                .insert(membersData);

            if (insertError) throw insertError;
        }

        return { id, ...data };
    }

    static async deleteGroup(id: string) {
        const { error } = await supabase
            .from("tree_groups")
            .delete()
            .eq("id", parseInt(id))
;

        if (error) throw error;
        return true;
    }
}
