import { Request, Response } from "express";
import { successResponse, errorResponse } from "../../utils/response";
import { supabase } from "../../config/supabaseClient";

export class StatsController {
    async getDashboardStats(req: Request, res: Response) {
        try {
            // 1. Get Total Trees
            const { count: totalTrees } = await supabase
                .from("trees")
                .select("*", { count: "exact", head: true });

            // 2. Get Total Quiz Questions
            const { count: totalQuizzes } = await supabase
                .from("quiz_questions")
                .select("*", { count: "exact", head: true });

            // 3. Get Total Similar Groups
            const { count: totalGroups } = await supabase
                .from("tree_groups")
                .select("*", { count: "exact", head: true });

            // 4. Get Active Users (7 days)
            let activeUsers = 0;
            const sevenDaysAgo = new Date();
            sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

            try {
                const { data: usersData } =
                    await supabase.auth.admin.listUsers();
                if (usersData?.users) {
                    activeUsers = usersData.users.filter(
                        (u) =>
                            u.last_sign_in_at &&
                            new Date(u.last_sign_in_at) > sevenDaysAgo,
                    ).length;
                }
            } catch (e) {
                // Fallback or ignore
            }

            const stats = {
                totalTrees: totalTrees || 0,
                totalQuizzes: totalQuizzes || 0,
                totalSimilarGroups: totalGroups || 0,
                activeUsers: activeUsers,
            };

            return successResponse(res, stats, "Dashboard stats retrieved");
        } catch (error) {
            console.error("Dashboard Stats Error:", error);
            return errorResponse(res, "Failed to fetch dashboard stats", 500);
        }
    }

    async getAdminDetailedStats(req: Request, res: Response) {
        try {
            const sevenDaysAgo = new Date();
            sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

            // 1. Quiz Exam Stats (Year-wise counts)
            const { data: examStats } = await supabase
                .from("quiz_exams")
                .select("year, round, title, id")
                .order("year", { ascending: false });

            // For each exam, count questions
            const examList = await Promise.all(
                (examStats || []).map(async (exam) => {
                    const { count } = await supabase
                        .from("quiz_questions")
                        .select("*", { count: "exact", head: true })
                        .eq("exam_id", exam.id);
                    return { ...exam, question_count: count || 0 };
                }),
            );

            // 2. Currently Active Users (Detailed categorization)
            let activeUserList: any[] = [];
            try {
                // Fetch all users from Auth
                const { data: authUsers } = await supabase.auth.admin.listUsers();
                
                // Fetch latest quiz activity for all users
                const { data: latestAttempts } = await supabase
                    .from("quiz_attempts")
                    .select("user_id, created_at")
                    .order("created_at", { ascending: false });

                // Map of user_id -> latest_activity_time
                const activityMap: Record<string, string> = {};
                latestAttempts?.forEach(att => {
                    if (!activityMap[att.user_id]) {
                        activityMap[att.user_id] = att.created_at;
                    }
                });

                if (authUsers?.users) {
                    activeUserList = authUsers.users
                        .map((u) => {
                            const authLogin = u.last_sign_in_at;
                            const quizLogin = activityMap[u.id];
                            
                            // Get the most recent time between Login and Quiz Activity
                            const finalLastActive = (authLogin && quizLogin) 
                                ? (new Date(authLogin) > new Date(quizLogin) ? authLogin : quizLogin)
                                : (authLogin || quizLogin || u.created_at);

                            return {
                                id: u.id,
                                email: u.email,
                                last_login: finalLastActive,
                                name: u.user_metadata?.name || u.email?.split("@")[0],
                                status: u.user_metadata?.status || "pending"
                            };
                        })
                        .sort((a, b) => {
                            return (
                                new Date(b.last_login!).getTime() -
                                new Date(a.last_login!).getTime()
                            );
                        });
                }
            } catch (e) {
                console.error("Error fetching grouped active users:", e);
            }

            // 3. Top 5 Wrong Trees
            const { data: wrongAttempts } = await supabase
                .from("quiz_attempts")
                .select("question_id")
                .eq("is_correct", false)
                .limit(1000);

            const wrongCounts: Record<number, number> = {};
            wrongAttempts?.forEach((a) => {
                wrongCounts[a.question_id] =
                    (wrongCounts[a.question_id] || 0) + 1;
            });

            const topQuestionIds = Object.entries(wrongCounts)
                .sort((a, b) => b[1] - a[1])
                .slice(0, 5);

            const topWrongTrees = await Promise.all(
                topQuestionIds.map(async ([qid, count]) => {
                    const { data: q } = await supabase
                        .from("quiz_questions")
                        .select("tree_id, name_kr")
                        .eq("id", qid)
                        .single();

                    let treeDetails = null;
                    if (q?.tree_id) {
                        const { data: tree } = await supabase
                            .from("trees")
                            .select(
                                "name_kr, scientific_name, family_name, description",
                            )
                            .eq("id", q.tree_id)
                            .single();
                        treeDetails = tree;
                    }

                    return {
                        name: q?.name_kr || "알 수 없는 수목",
                        count: count,
                        details: treeDetails,
                    };
                }),
            );

            // 4. Recent Updates (Last 7 Days)
            const { count: newTrees } = await supabase
                .from("trees")
                .select("*", { count: "exact", head: true })
                .gt("created_at", sevenDaysAgo.toISOString());

            const { count: newQuizzes } = await supabase
                .from("quiz_questions")
                .select("*", { count: "exact", head: true })
                .gt("created_at", sevenDaysAgo.toISOString());

            const { count: newSimilar } = await supabase
                .from("tree_groups")
                .select("*", { count: "exact", head: true })
                .gt("created_at", sevenDaysAgo.toISOString());

            // 0. Global Totals (Requested for Admin Dashboard)
            const { count: totalTreesAll } = await supabase
                .from("trees")
                .select("*", { count: "exact", head: true });
            const { count: totalSimilarAll } = await supabase
                .from("tree_groups")
                .select("*", { count: "exact", head: true });
            const { count: totalQuizzesAll } = await supabase
                .from("quiz_questions")
                .select("*", { count: "exact", head: true });

            return successResponse(
                res,
                {
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
                },
                "Admin detailed stats retrieved",
            );
        } catch (error) {
            console.error("Admin Detailed Stats Error:", error);
            return errorResponse(res, "Failed to fetch detailed stats", 500);
        }
    }

    async getUserPerformanceStats(req: Request, res: Response) {
        try {
            // Priority: path param (for admin view) > query param (fallback) > auth user (for personal view)
            const userId =
                req.params.userId ||
                (req.query.user_id as string) ||
                (req as any).user?.id;

            if (!userId) {
                return errorResponse(res, "User ID is required", 400);
            }

            // 1. Fetch total published questions and tree count
            const { data: questions } = await supabase
                .from("quiz_questions")
                .select("id, exam_id")
                .eq("status", "published");

            const { count: treeCount } = await supabase
                .from("trees")
                .select("*", { count: "exact", head: true });

            const totalExamIds = (questions || [])
                .filter((q) => q.exam_id !== null)
                .map((q) => q.id);

            // 2. Fetch user's attempts
            const { data: attempts } = await supabase
                .from("quiz_attempts")
                .select("question_id, is_correct")
                .eq("user_id", userId);

            // 3. Process General Quizzes (Tree Quizzes & non-exam questions)
            const solvedGeneralSet = new Set();
            let generalCorrect = 0;
            let generalWrong = 0;

            // 4. Process Past Exams (exam_id is not null)
            const solvedExamSet = new Set();
            let examCorrect = 0;
            let examWrong = 0;

            const examQuestionIds = new Set(totalExamIds);

            attempts?.forEach((att) => {
                if (examQuestionIds.has(att.question_id)) {
                    solvedExamSet.add(att.question_id);
                    if (att.is_correct) examCorrect++;
                    else examWrong++;
                } else {
                    // Treat as General Quiz (Tree Quiz)
                    solvedGeneralSet.add(att.question_id);
                    if (att.is_correct) generalCorrect++;
                    else generalWrong++;
                }
            });

            // 5. Fetch user info (especially for admin view)
            let userInfo = null;
            try {
                const { data } = await supabase.auth.admin.getUserById(userId);
                if (data?.user) {
                    userInfo = {
                        name:
                            data.user.user_metadata?.name ||
                            data.user.email?.split("@")[0],
                        email: data.user.email,
                        lastSignIn: data.user.last_sign_in_at,
                    };
                }
            } catch (e) {}

            const response = {
                user: userInfo,
                quiz: {
                    totalCount: treeCount || 0, // Using tree count as potential pool for Tree Quizzes
                    solvedCount: solvedGeneralSet.size,
                    correctCount: generalCorrect,
                    wrongCount: generalWrong,
                },
                pastExam: {
                    totalCount: totalExamIds.length,
                    solvedCount: solvedExamSet.size,
                    correctCount: examCorrect,
                    wrongCount: examWrong,
                },
            };

            return successResponse(
                res,
                response,
                "User performance stats retrieved",
            );
        } catch (error: any) {
            console.error("User Performance Stats Error:", error.message);
            return errorResponse(res, error.message, 500);
        }
    }

    async getUserDashboardStats(req: Request, res: Response) {
        try {
            // 1. Total Trees
            const { count: totalTrees } = await supabase
                .from("trees")
                .select("*", { count: "exact", head: true });

            // 2. Total Quiz Questions
            const { count: totalQuizzes } = await supabase
                .from("quiz_questions")
                .select("*", { count: "exact", head: true });

            // 3. Total Similar Groups
            const { count: totalGroups } = await supabase
                .from("tree_groups")
                .select("*", { count: "exact", head: true });

            const stats = {
                totalTrees: totalTrees || 0,
                totalQuizzes: totalQuizzes || 0,
                totalSimilarGroups: totalGroups || 0,
            };

            return successResponse(
                res,
                stats,
                "User dashboard stats retrieved",
            );
        } catch (error) {
            console.error("User Stats Error:", error);
            return errorResponse(res, "Failed to fetch user stats", 500);
        }
    }
}

export const statsController = new StatsController();
