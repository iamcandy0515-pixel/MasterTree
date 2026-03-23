import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/models/quiz_model.dart';
import 'package:flutter_user_app/utils/quiz_data_mapper.dart';

class QuizRepository {
  // Instance methods for new controllers
  Future<List<QuizQuestion>> fetchQuizzes() async {
    try {
      final List<Map<String, dynamic>> data = await ApiService.getTrees(limit: 100);
      if (data.isNotEmpty) {
        return QuizDataMapper.mapToQuestions(data);
      }
      return QuizDataMapper.getDummyData();
    } catch (e) {
      return QuizDataMapper.getDummyData();
    }
  }

  void saveAttempt({
    required int treeId,
    required bool isCorrect,
    required int userAnswer,
  }) {
    ApiService.addPendingAttempt({
      'tree_id': treeId,
      'is_correct': isCorrect,
      'user_answer': userAnswer,
      'time_taken_ms': 0,
      'mode': 'normal',
    });
  }

  // Static methods for legacy provider compatibility
  static Future<List<QuizQuestion>> fetchQuestions() {
    return QuizRepository().fetchQuizzes();
  }

  static QuizQuestion getDummyQuestion() {
    return QuizDataMapper.getDummyData().first;
  }
}
