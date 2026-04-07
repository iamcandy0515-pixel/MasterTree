import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../repositories/quiz_media_repository.dart';

mixin QuizImageHandlerMixin on ChangeNotifier {
  final QuizMediaRepository _repository = QuizMediaRepository();

  bool _isImageLoading = false;
  bool get isImageLoading => _isImageLoading;

  Future<void> addImageToQuizInternal(String field, Uint8List bytes, String name, Map<String, dynamic>? data) async {
    if (data == null) return;
    try {
      _isImageLoading = true;
      notifyListeners();
      final url = await _repository.uploadQuizImage(bytes, name);

      final key = (field == 'question') ? 'content_blocks' : 'explanation_blocks';
      List<dynamic> blocks = List<dynamic>.from(data[key] as Iterable? ?? <dynamic>[]);
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
    return (blocks != null) && blocks.any((dynamic b) => b['type'] == 'image');
  }

  void removeImageInternal(String field, int index, Map<String, dynamic>? data) {
    if (data == null) return;
    final key = (field == 'question') ? 'content_blocks' : 'explanation_blocks';
    List<dynamic> blocks = List<dynamic>.from(data[key] as Iterable? ?? <dynamic>[]);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
      data[key] = blocks;
      notifyListeners();
    }
  }
}
