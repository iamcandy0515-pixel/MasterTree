import 'package:flutter/material.dart';
import '../../repositories/quiz_ai_repository.dart';

mixin QuizAiAssistantMixin on ChangeNotifier {
  final QuizAiRepository _repository = QuizAiRepository();

  bool _isRecommending = false;
  bool get isRecommending => _isRecommending;

  bool _isReviewing = false;
  bool get isReviewing => _isReviewing;

  List<Map<String, dynamic>> _relatedQuestions = [];
  List<Map<String, dynamic>> get relatedQuestions => _relatedQuestions;

  Future<void> recommendRelatedAction(String questionText) async {
    if (questionText.isEmpty) throw '문제를 먼저 추출하거나 입력해주세요.';
    _isRecommending = true;
    notifyListeners();

    try {
      final dynamic rawRelated = await _repository.recommendRelated(questionText: questionText, limit: 10);
      if (rawRelated is List) {
        // 🔥 [Recursive FTF] Deep cast every element to survive minified JS runtime
        _relatedQuestions = (rawRelated as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        _relatedQuestions = [];
      }
    } catch (e) {
      debugPrint('❌ [QuizAiAssistantMixin] Recommend error: $e');
      _relatedQuestions = [];
    } finally {
      _isRecommending = false;
      notifyListeners();
    }
  }

  Future<List<String>> generateDistractorsAction(String questionText, String correctAnswer) async {
    if (questionText.isEmpty || correctAnswer.isEmpty) throw '문제와 정답 내용을 확인해주세요.';
    try {
      final List<dynamic> rawDistractors = await _repository.generateDistractors(questionText, correctAnswer);
      return rawDistractors.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('❌ [QuizAiAssistantMixin] GenerateDistractors error: $e');
      return [];
    }
  }

  Future<List<String>> generateHintsInternal(String questionText, String explanation, int hintsCount) async {
    if (questionText.isEmpty || explanation.isEmpty) throw '문제와 해설 내용을 확인해주세요.';
    try {
      final List<dynamic> rawHints = await _repository.generateHints(questionText, explanation, hintsCount);
      return rawHints.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('❌ [QuizAiAssistantMixin] GenerateHints error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> reviewExplanationInternal(String explanationText, Map<String, dynamic>? extractedBlock) async {
    final rawText = extractedBlock?['raw_source_text'] ?? '';
    if (rawText.isEmpty || explanationText.isEmpty) throw '원문 텍스트 또는 해설 내용이 없습니다.';

    _isReviewing = true;
    notifyListeners();

    try {
      final dynamic rawReview = await _repository.reviewQuizAlignment(rawText, [{'type': 'text', 'content': explanationText}]);
      if (rawReview is! Map) return <String, dynamic>{'error': '잘못된 리뷰 데이터 형식'};
      
      return Map<String, dynamic>.from(rawReview as Map);
    } catch (e) {
      debugPrint('❌ [QuizAiAssistantMixin] Review error: $e');
      return <String, dynamic>{'error': e.toString()};
    } finally {
      _isReviewing = false;
      notifyListeners();
    }
  }
}
