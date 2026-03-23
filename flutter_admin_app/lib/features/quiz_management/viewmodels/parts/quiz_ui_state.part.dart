part of '../quiz_review_detail_viewmodel.dart';

extension QuizUiState on QuizReviewDetailViewModel {
  String _extractTextFromBlocks(List<dynamic> blocks) {
    return blocks.map((b) {
      if (b is Map && b['type'] == 'text') return b['content']?.toString() ?? '';
      if (b is String) return b;
      return '';
    }).where((t) => t.isNotEmpty).join('\n');
  }

  void toggleExpanded(String field) {
    if (field == 'content') {
      isContentExpanded = !isContentExpanded;
    } else {
      isExpExpanded = !isExpExpanded;
    }
    notifyListeners();
  }

  void setRelatedPage(int page) { 
    currentRelatedPage = page; 
    notifyListeners(); 
  }

  void removeRelated(int id) {
    selectedRelatedIds.remove(id);
    relatedQuizzesMetadata.removeWhere((m) => m['id'] == id);
    notifyListeners();
  }
}
