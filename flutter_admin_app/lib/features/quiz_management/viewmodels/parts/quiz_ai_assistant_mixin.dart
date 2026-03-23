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
      final related = await _repository.recommendRelated(questionText: questionText, limit: 10);
      _relatedQuestions = List<Map<String, dynamic>>.from(related);
    } catch (e) {
      throw e.toString();
    } finally {
      _isRecommending = false;
      notifyListeners();
    }
  }

  Future<List<String>> generateDistractorsAction(String questionText, String correctAnswer) async {
    if (questionText.isEmpty || correctAnswer.isEmpty) throw '문제와 현재 지정된 정답 내용을 확인해주세요.';
    try {
      return await _repository.generateDistractors(questionText, correctAnswer);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<String>> generateHintsInternal(String questionText, String explanation, int hintsCount) async {
    if (questionText.isEmpty || explanation.isEmpty) throw '문제와 해설 내용을 먼저 확인해주세요.';
    try {
      return await _repository.generateHints(questionText, explanation, hintsCount);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> reviewExplanationInternal(String explanationText, Map<String, dynamic>? extractedBlock) async {
    final rawText = extractedBlock?['raw_source_text'] ?? '';
    if (rawText.isEmpty || explanationText.isEmpty) throw '원문 텍스트 또는 해설 내용이 없습니다.';

    _isReviewing = true;
    notifyListeners();

    try {
      final reviewData = await _repository.reviewQuizAlignment(rawText, [{'type': 'text', 'content': explanationText}]);
      return reviewData;
    } catch (e) {
      throw e.toString();
    } finally {
      _isReviewing = false;
      notifyListeners();
    }
  }
}
