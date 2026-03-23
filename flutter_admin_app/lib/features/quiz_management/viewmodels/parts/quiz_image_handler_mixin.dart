import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../repositories/quiz_repository.dart';

mixin QuizImageHandlerMixin on ChangeNotifier {
  final QuizRepository _repository = QuizRepository();

  bool _isImageLoading = false;
  bool get isImageLoading => _isImageLoading;

  Future<void> addImageToQuizInternal(String field, XFile file, Map<String, dynamic>? data) async {
    if (data == null) return;
    try {
      _isImageLoading = true;
      notifyListeners();
      final bytes = await file.readAsBytes();
      final url = await _repository.uploadQuizImage(bytes, file.name);

      final key = (field == 'question') ? 'content_blocks' : 'explanation_blocks';
      List blocks = List.from(data[key] ?? []);
      blocks.add({'type': 'image', 'content': url});
      data[key] = blocks;
      notifyListeners();
    } finally {
      _isImageLoading = false;
      notifyListeners();
    }
  }

  bool hasImageInternal(String field, Map<String, dynamic>? data) {
    if (data == null) return false;
    final key = (field == 'question') ? 'content_blocks' : 'explanation_blocks';
    final blocks = data[key] as List?;
    return (blocks != null) && blocks.any((b) => b['type'] == 'image');
  }

  void removeImageInternal(String field, int index, Map<String, dynamic>? data) {
    if (data == null) return;
    final key = (field == 'question') ? 'content_blocks' : 'explanation_blocks';
    List blocks = List.from(data[key] ?? []);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
      data[key] = blocks;
      notifyListeners();
    }
  }
}
