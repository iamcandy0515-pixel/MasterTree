import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_media_repository.dart';

mixin BulkMediaMixin on ChangeNotifier {
  final QuizMediaRepository mediaRepo = QuizMediaRepository();

  /// Adds an image to a specific quiz block
  Future<String?> uploadAndAddImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final parts = file.name.split('.');
      final ext = parts.length > 1 ? parts.last : 'png';
      final safeName = 'gallery_${DateTime.now().millisecondsSinceEpoch}.$ext';
      return await uploadImageBytes(bytes, safeName);
    } catch (e) {
      debugPrint('Error uploading image (XFile) in media mixin: $e');
      return null;
    }
  }

  /// Direct byte upload for clipboard or other raw data
  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      final url = await mediaRepo.uploadQuizImage(bytes, fileName);
      return url;
    } catch (e) {
      debugPrint('Error uploading image (Bytes) in media mixin: $e');
      return null;
    }
  }

  /// Helper to ensure a quiz entry exists in the local map
  Map<String, dynamic> createInitialQuizEntry(int qNum) {
    return <String, dynamic>{
      'question_number': qNum,
      'question': [],
      'explanation': [],
      'options': [],
    };
  }
}
