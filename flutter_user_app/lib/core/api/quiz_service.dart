import 'package:flutter/foundation.dart';
import '../constants.dart';
import 'base_api_service.dart';

class QuizService {
  static Future<void> submitQuizAttempt({
    required int questionId,
    required bool isCorrect,
    required String userAnswer,
    int? categoryId,
    int? sessionId,
    int timeTakenMs = 0,
  }) async {
    final url = Uri.parse('${AppConstants.apiUrl}/user-quiz/attempt');
    try {
      await BaseApiService.post(url, {
        'question_id': questionId,
        'session_id': sessionId,
        'category_id': categoryId,
        'is_correct': isCorrect,
        'user_answer': userAnswer,
        'time_taken_ms': timeTakenMs,
      });
    } catch (e) {
      debugPrint('QuizService.submitQuizAttempt Error: $e');
    }
  }

  static Future<bool> submitQuizSessionAttempts({
    required int sessionId,
    required List<Map<String, dynamic>> attempts,
  }) async {
    final url = Uri.parse('${AppConstants.apiUrl}/user-quiz/submit');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.post(url, {
        'session_id': sessionId,
        'attempts': attempts,
      });
      return jsonResponse['success'] == true;
    } catch (e) {
      debugPrint('QuizService.submitQuizSessionAttempts Error: $e');
      return false;
    }
  }

  static Future<bool> submitBatchAttempts(List<Map<String, dynamic>> attempts) async {
    if (attempts.isEmpty) return true;
    final url = Uri.parse('${AppConstants.apiUrl}/user-quiz/batch');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.post(url, {'attempts': attempts});
      return jsonResponse['success'] == true;
    } catch (e) {
      debugPrint('QuizService.submitBatchAttempts Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> generateQuizSession({
    String mode = 'normal',
    int limit = 10,
  }) async {
    final url = Uri.parse('${AppConstants.apiUrl}/user-quiz/generate');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.post(url, <String, dynamic>{
        'mode': mode,
        'limit': limit,
      });
      if (jsonResponse['success'] == true) {
        return Map<String, dynamic>.from((jsonResponse['data'] as Map<dynamic, dynamic>?) ?? <String, dynamic>{});
      }
      throw Exception('세션 생성 실패: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('QuizService.generateQuizSession Error: $e');
      rethrow;
    }
  }
}
