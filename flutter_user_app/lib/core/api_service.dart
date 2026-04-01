import 'api/tree_service.dart';
import 'api/quiz_service.dart';
import 'api/stats_service.dart';
import 'api/sync_service.dart';

class ApiService {
  // Tree
  static Future<List<Map<String, dynamic>>> getTrees({
    int page = 1,
    int limit = 100,
    String? search,
    String? category,
    bool minimal = true,
  }) => TreeService.getTrees(page: page, limit: limit, search: search, category: category, minimal: minimal);

  static Future<Map<String, dynamic>?> getTreeOne(int id) => TreeService.getTreeOne(id);

  static Future<List<Map<String, dynamic>>> getTreeImages(int treeId) => TreeService.getTreeImages(treeId);

  static String getProxyImageUrl(String? url, {int? width, int? height}) => TreeService.getProxyImageUrl(url, width: width, height: height);

  // Groups
  static Future<List<Map<String, dynamic>>> getTreeGroups() => GroupService.getTreeGroups();

  static Future<Map<String, dynamic>> getTreeGroup(String id) => GroupService.getTreeGroup(id);

  // Stats
  static Future<Map<String, dynamic>> getUserStats() => StatsService.getUserStats();

  static Future<Map<String, dynamic>> getUserPerformanceStats() => StatsService.getUserPerformanceStats();

  // Sync
  static Future<void> init() => SyncService.init();

  static void addPendingAttempt(Map<String, dynamic> attempt) => SyncService.addPendingAttempt(attempt);

  static Future<void> syncPendingAttempts() => SyncService.syncPendingAttempts();

  // Quiz
  static Future<void> submitQuizAttempt({
    required int questionId,
    required bool isCorrect,
    required String userAnswer,
    int? categoryId,
    int? sessionId,
    int timeTakenMs = 0,
  }) => QuizService.submitQuizAttempt(
    questionId: questionId,
    isCorrect: isCorrect,
    userAnswer: userAnswer,
    categoryId: categoryId,
    sessionId: sessionId,
    timeTakenMs: timeTakenMs,
  );

  static Future<bool> submitQuizSessionAttempts({
    required int sessionId,
    required List<Map<String, dynamic>> attempts,
  }) => QuizService.submitQuizSessionAttempts(sessionId: sessionId, attempts: attempts);

  static Future<bool> submitBatchAttempts(List<Map<String, dynamic>> attempts) => QuizService.submitBatchAttempts(attempts);

  static Future<Map<String, dynamic>> generateQuizSession({
    String mode = 'normal',
    int limit = 10,
  }) => QuizService.generateQuizSession(mode: mode, limit: limit);
}
