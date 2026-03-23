import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_media_repository.dart';

mixin BulkMediaMixin on ChangeNotifier {
  final QuizMediaRepository mediaRepo = QuizMediaRepository();

  /// Adds an image to a specific quiz block
  Future<String?> uploadAndAddImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final url = await mediaRepo.uploadQuizImage(bytes, file.name);
      return url;
    } catch (e) {
      debugPrint('Error uploading image in media mixin: $e');
      return null;
    }
  }

  /// Helper to ensure a quiz entry exists in the local map
  Map<String, dynamic> createInitialQuizEntry(int qNum) {
    return {
      'question_number': qNum,
      'question': [],
      'explanation': [],
      'options': [],
    };
  }
}
