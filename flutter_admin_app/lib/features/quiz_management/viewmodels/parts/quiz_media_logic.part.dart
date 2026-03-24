part of '../quiz_review_detail_viewmodel.dart';

extension QuizMediaLogic on QuizReviewDetailViewModel {
  Future<void> uploadImage(Uint8List bytes, String name, String field) async {
    final url = await _mediaRepo.uploadQuizImage(bytes, name);
    if (field == 'content') {
      contentBlocks.add({'type': 'image', 'content': url});
    } else {
      explanationBlocks.add({'type': 'image', 'content': url});
    }
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }

  void removeImage(int blockIdx, String field) {
    if (field == 'content') {
      contentBlocks.removeAt(blockIdx);
    } else {
      explanationBlocks.removeAt(blockIdx);
    }
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }
}
