part of '../quiz_review_detail_viewmodel.dart';

extension QuizAiLogic on QuizReviewDetailViewModel {
  Future<Map<String, dynamic>> aiReview() async {
    _isReviewing = true;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
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
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();
      return res;
    } catch (e) {
      _isReviewing = false;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();
      rethrow;
    }
  }

  Future<void> generateDistractors() async {
    _isGenerating = true;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
    try {
      final distractors = await _aiRepo.generateDistractors(questionText, correctOption);
      incorrectOptions = distractors;
      _isGenerating = false;
    } catch (e) {
      _isGenerating = false;
      rethrow;
    }
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }

  Future<List<dynamic>> recommendSimilar(int quizId) async {
    _isRecommending = true;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
    try {
      final related = await _aiRepo.recommendRelated(questionText: questionText);
      _isRecommending = false;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();
      return related.where((r) => r['id'] != quizId).toList();
    } catch (e) {
      _isRecommending = false;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();
      rethrow;
    }
  }
}
