import { supabase } from "../../../config/supabaseClient";

export class StatsUserService {
    async getUserPerformanceStats(userId: string) {
        // [Optimized] Fetch basic stats from aggregation tables
        const [
            { data: treeStats },
            { data: examStats },
            { data: userData }
        ] = await Promise.all([
            (supabase as any).from("user_tree_category_stats").select("mastered_count, total_count").eq("user_id", userId),
            (supabase as any).from("user_exam_session_stats").select("mastered_count, total_count").eq("user_id", userId),
            (supabase as any).auth.admin.getUserById(userId)
        ]);

        const treeTotal = (treeStats as any[])?.reduce((acc, s) => acc + (s.total_count || 0), 0) || 0;
        const treeCorrect = (treeStats as any[])?.reduce((acc, s) => acc + (s.mastered_count || 0), 0) || 0;
        
        const examTotal = (examStats as any[])?.reduce((acc, s) => acc + (s.total_count || 0), 0) || 0;
        const examCorrect = (examStats as any[])?.reduce((acc, s) => acc + (s.mastered_count || 0), 0) || 0;

        let userInfo = null;
        if (userData?.user) {
            userInfo = {
                name: userData.user.user_metadata?.name || userData.user.email?.split("@")[0],
                email: userData.user.email,
                lastSignIn: userData.user.last_sign_in_at,
            };
        }

        return {
            user: userInfo,
            quiz: {
                totalCount: Number(treeTotal),
                masteredCount: Number(treeCorrect),
                accuracyRate: treeTotal > 0 ? (treeCorrect / treeTotal) * 100 : 0
            },
            pastExam: {
                totalCount: Number(examTotal),
                masteredCount: Number(examCorrect),
                accuracyRate: examTotal > 0 ? (examCorrect / examTotal) * 100 : 0
            },
        };
    }

    /**
     * Get detailed tree category statistics for the UI list.
     */
    async getTreeCategoryStats(userId: string) {
        const { data, error } = await (supabase as any)
            .from("user_tree_category_stats")
            .select("*")
            .eq("user_id", userId)
            .order("category_name", { ascending: true });
        
        if (error) throw error;
        return data || [];
    }

    /**
     * Get detailed exam session statistics for the UI list.
     */
    async getExamSessionStats(userId: string) {
        const { data, error } = await (supabase as any)
            .from("user_exam_session_stats")
            .select("*")
            .eq("user_id", userId)
            .order("updated_at", { ascending: false });
        
        if (error) throw error;
        return data || [];
    }
}

export const statsUserService = new StatsUserService();
