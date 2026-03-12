import { supabase } from "../../../config/supabaseClient";

export class StatsAdminService {
    async getAdminDetailedStats() {
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        // 1. Quiz Exam Stats (Year-wise counts)
        const { data: examStats } = await supabase
            .from("quiz_exams")
            .select("year, round, title, id")
            .order("year", { ascending: false });

        const examList = await Promise.all(
            (examStats || []).map(async (exam) => {
                const { count } = await supabase
                    .from("quiz_questions")
                    .select("*", { count: "exact", head: true })
                    .eq("exam_id", exam.id);
                return { ...exam, question_count: count || 0 };
            }),
        );

        // 2. Currently Active Users (Detailed categorization with stats counts)
        const { data: authUsers } = await supabase.auth.admin.listUsers();
        const { data: questions } = await supabase
            .from("quiz_questions")
            .select("id, exam_id");

        const examQuestionIds = new Set(
            (questions || [])
                .filter(q => q.exam_id !== null)
                .map(q => q.id)
        );

        const { data: allAttempts } = await supabase
            .from("quiz_attempts")
            .select("user_id, question_id, tree_id, created_at");

        const userAggregates: Record<string, { last_active: string | null, tree_count: number, exam_count: number, solved_set: Set<string | number> }> = {};
        
        allAttempts?.forEach(att => {
            if (!userAggregates[att.user_id]) {
                userAggregates[att.user_id] = { 
                    last_active: att.created_at, 
                    tree_count: 0, 
                    exam_count: 0,
                    solved_set: new Set()
                };
            }
            
            if (!userAggregates[att.user_id].last_active || new Date(att.created_at) > new Date(userAggregates[att.user_id].last_active!)) {
                userAggregates[att.user_id].last_active = att.created_at;
            }

            const qId = att.question_id;
            const tId = att.tree_id;

            if (qId && examQuestionIds.has(qId)) {
                if (!userAggregates[att.user_id].solved_set.has(`q_${qId}`)) {
                    userAggregates[att.user_id].solved_set.add(`q_${qId}`);
                    userAggregates[att.user_id].exam_count++;
                }
            } else {
                const globalId = tId ? `t_${tId}` : qId ? `q_${qId}` : null;
                if (globalId && !userAggregates[att.user_id].solved_set.has(globalId)) {
                    userAggregates[att.user_id].solved_set.add(globalId);
                    userAggregates[att.user_id].tree_count++;
                }
            }
        });

        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const activeUserList = (authUsers?.users || [])
            .filter((u) => u.user_metadata?.status !== "rejected")
            .map((u) => {
                const aggregates = userAggregates[u.id];
                const authLogin = u.last_sign_in_at;
                const quizActivity = aggregates?.last_active;
                const finalLastActive = (authLogin && quizActivity) 
                    ? (new Date(authLogin) > new Date(quizActivity) ? authLogin : quizActivity)
                    : (authLogin || quizActivity || u.created_at);

                return {
                    id: u.id,
                    email: u.email,
                    last_login: finalLastActive,
                    name: u.user_metadata?.name || u.email?.split("@")[0],
                    status: u.user_metadata?.status || "pending",
                    role: u.user_metadata?.role || "user",
                    tree_quiz_count: aggregates?.tree_count || 0,
                    exam_quiz_count: aggregates?.exam_count || 0,
                    is_active_tab: finalLastActive ? new Date(finalLastActive) > thirtyDaysAgo : false
                };
            })
            .sort((a, b) => {
                const dateA = a.last_login ? new Date(a.last_login).getTime() : 0;
                const dateB = b.last_login ? new Date(b.last_login).getTime() : 0;
                return dateB - dateA;
            });

        // 3. Top 5 Wrong Trees
        const { data: wrongAttempts } = await supabase
            .from("quiz_attempts")
            .select("question_id, tree_id")
            .eq("is_correct", false)
            .limit(1000);

        const wrongCounts: Record<string, number> = {};
        wrongAttempts?.forEach((a) => {
            const key = a.tree_id ? `t_${a.tree_id}` : `q_${a.question_id}`;
            wrongCounts[key] = (wrongCounts[key] || 0) + 1;
        });

        const topKeys = Object.entries(wrongCounts)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 5);

        const topWrongTrees = await Promise.all(
            topKeys.map(async ([key, count]) => {
                let name = "알 수 없는 수목";
                let treeId = null;
                
                if (key.startsWith("t_")) {
                    treeId = parseInt(key.split("_")[1]);
                } else {
                    const qid = parseInt(key.split("_")[1]);
                    const { data: q } = await supabase.from("quiz_questions").select("tree_id, name_kr").eq("id", qid).single();
                    name = q?.name_kr || name;
                    treeId = q?.tree_id;
                }

                let treeDetails = null;
                if (treeId) {
                    const { data: tree } = await supabase.from("trees").select("name_kr, scientific_name, family_name, description").eq("id", treeId).single();
                    treeDetails = tree;
                    name = tree?.name_kr || name;
                }

                return { name, count, details: treeDetails };
            }),
        );

        // 4. Recent Updates
        const { count: newTrees } = await supabase.from("trees").select("*", { count: "exact", head: true }).gt("created_at", sevenDaysAgo.toISOString());
        const { count: newQuizzes } = await supabase.from("quiz_questions").select("*", { count: "exact", head: true }).gt("created_at", sevenDaysAgo.toISOString());
        const { count: newSimilar } = await supabase.from("tree_groups").select("*", { count: "exact", head: true }).gt("created_at", sevenDaysAgo.toISOString());

        const { count: totalTreesAll } = await supabase.from("trees").select("*", { count: "exact", head: true });
        const { count: totalSimilarAll } = await supabase.from("tree_groups").select("*", { count: "exact", head: true });
        const { count: totalQuizzesAll } = await supabase.from("quiz_questions").select("*", { count: "exact", head: true });

        return {
            globalStats: {
                totalTrees: totalTreesAll || 0,
                totalSimilar: totalSimilarAll || 0,
                totalQuizzes: totalQuizzesAll || 0,
                activeUserCount: activeUserList.length,
            },
            exams: examList,
            activeUsers: activeUserList,
            topWrongTrees,
            updateSummary: {
                trees: newTrees || 0,
                quizzes: newQuizzes || 0,
                similar: newSimilar || 0,
            },
        };
    }
}

export const statsAdminService = new StatsAdminService();
