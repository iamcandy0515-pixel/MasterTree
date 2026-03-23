part of '../quiz_review_detail_viewmodel.dart';

extension QuizAiLogic on QuizReviewDetailViewModel {
  Future<Map<String, dynamic>> aiReview() async {
    _isReviewing = true;
    notifyListeners();
    try {
      final rawText = relatedQuizzesMetadata.isNotEmpty 
          ? _extractTextFromBlocks(relatedQuizzesMetadata.first['content_blocks'] ?? []) 
          : '';
      final res = await _aiRepo.reviewQuizAlignment(
        rawText, 
        [{'type': 'text', 'content': explanationText}]
      );
      _isReviewing = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isReviewing = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> generateDistractors() async {
    _isGenerating = true;
    notifyListeners();
    try {
      final distractors = await _aiRepo.generateDistractors(questionText, correctOption);
      incorrectOptions = distractors;
      _isGenerating = false;
    } catch (e) {
      _isGenerating = false;
      rethrow;
    }
    notifyListeners();
  }

  Future<List<dynamic>> recommendSimilar(int quizId) async {
    _isRecommending = true;
    notifyListeners();
    try {
      final related = await _aiRepo.recommendRelated(questionText: questionText);
      _isRecommending = false;
      notifyListeners();
      return related.where((r) => r['id'] != quizId).toList();
    } catch (e) {
      _isRecommending = false;
      notifyListeners();
      rethrow;
    }
  }
}
