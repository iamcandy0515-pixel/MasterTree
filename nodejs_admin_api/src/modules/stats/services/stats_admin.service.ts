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
        
        // [수정] quiz_attempts 대신 user_quiz_summary 기반으로 집계 (더 정확하고 빠름)
        const { data: qSummary } = await (supabase as any)
            .from("user_quiz_summary")
            .select("user_id, updated_at, tree_id, question_id, is_last_correct");

        // 퀴즈 타입 구분을 위해 문제 데이터 맵핑 필요 (exam_id 유무)
        const { data: questions } = await supabase
            .from("quiz_questions")
            .select("id, exam_id");

        const examQuestionIds = new Set(
            (questions || [])
                .filter(q => q.exam_id !== null)
                .map(q => q.id)
        );

        const userAggregates: Record<string, { last_active: string | null, tree_count: number, exam_count: number }> = {};
        
        // 오답 랭킹을 위한 집계 (이것은 최근 실적 기반)
        const wrongCounts: Record<string, number> = {};

        qSummary?.forEach((s: any) => {
            const uid = s.user_id as string;
            const qId = s.question_id as number;
            const tId = s.tree_id as number;

            if (!userAggregates[uid]) {
                userAggregates[uid] = { 
                    last_active: null, 
                    tree_count: 0, 
                    exam_count: 0 
                };
            }
            
            // 마지막 활동 시점 업데이트
            if (!userAggregates[uid].last_active || new Date(s.updated_at) > new Date(userAggregates[uid].last_active!)) {
                userAggregates[uid].last_active = s.updated_at;
            }

            // 건수 합산 (user_quiz_summary는 사용자/문제별 1개 레코드이므로 단순히 COUNT 가능)
            if (qId && examQuestionIds.has(qId)) {
                userAggregates[uid].exam_count++;
            } else if (tId || qId) {
                userAggregates[uid].tree_count++;
            }

            // 오답 랭킹용 집계
            if (s.is_last_correct === false) {
                const wrongKey = tId ? `t_${tId}` : (qId ? `q_${qId}` : null);
                if (wrongKey) {
                    wrongCounts[wrongKey] = (wrongCounts[wrongKey] || 0) + 1;
                }
            }
        });

        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const activeUserList = (authUsers?.users || [])
            .filter((u) => u.user_metadata?.status !== "rejected")
            .map((u) => {
                const aggregates = userAggregates[u.id];
                // [변경] 활동 시점은 퀴즈 활동 기반 (로그인 기록 제외 요청 반영)
                const quizActivity = aggregates?.last_active;
                const finalLastActive = quizActivity || null;

                return {
                    id: u.id,
                    email: u.email,
                    last_login: finalLastActive || u.last_sign_in_at || u.created_at, // 표시용은 로그인 포함 가능
                    name: u.user_metadata?.name || u.email?.split("@")[0],
                    status: u.user_metadata?.status || "pending",
                    role: u.user_metadata?.role || "user",
                    tree_quiz_count: aggregates?.tree_count || 0,
                    exam_quiz_count: aggregates?.exam_count || 0,
                    // [변경] '활동 중인 유저' 기준: 30일 이내 퀴즈 풀이 실적(1건이라도)이 있는 사람
                    is_active_tab: quizActivity ? new Date(quizActivity) > thirtyDaysAgo : false
                };
            })
            .sort((a, b) => {
                const dateA = a.last_login ? new Date(a.last_login).getTime() : 0;
                const dateB = b.last_login ? new Date(b.last_login).getTime() : 0;
                return dateB - dateA;
            });

        // 3. Top 5 Wrong Trees Ranking
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
