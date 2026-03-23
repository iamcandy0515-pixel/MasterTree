import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_repository.dart';
import 'mixins/tree_media_mixin.dart';
import 'mixins/tree_quiz_mixin.dart';

/// 수목 추가/수정 ViewModel (Refactored with Mixins)
class AddTreeViewModel extends ChangeNotifier with TreeMediaMixin, TreeQuizMixin {
  final MasterTreeRepository _repo = MasterTreeRepository();
  final Tree? originalTree;

  // Form Fields
  final TextEditingController nameKrController = TextEditingController();
  final TextEditingController scientificNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? _selectedCategory;
  int _difficulty = 1;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Getters
  String? get selectedCategory => _selectedCategory;
  int get difficulty => _difficulty;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  AddTreeViewModel(this.originalTree) {
    if (originalTree != null) {
      nameKrController.text = originalTree!.nameKr;
      scientificNameController.text = originalTree!.scientificName ?? '';
      descriptionController.text = originalTree!.description ?? '';
      _selectedCategory = originalTree!.category;
      _difficulty = originalTree!.difficulty;
      
      // Initialize Mixins
      initializeImages(originalTree!.images);
      initializeQuiz(originalTree!.quizDistractors, originalTree!.isAutoQuizEnabled);
    }
  }

  @override
  void dispose() {
    nameKrController.dispose();
    scientificNameController.dispose();
    descriptionController.dispose();
    disposeQuiz();
    super.dispose();
  }

  // Setters
  void setSelectedCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setDifficulty(int value) {
    _difficulty = value;
    notifyListeners();
  }

  Future<bool> submitTree() async {
    if (uploadedImages.isEmpty) {
      throw Exception('최소 1개 이상의 이미지를 업로드해주세요');
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CreateTreeRequest(
        nameKr: nameKrController.text.trim(),
        scientificName: scientificNameController.text.trim(),
        description: descriptionController.text.trim(),
        category: _selectedCategory,
        difficulty: _difficulty,
        images: uploadedImages,
        quizDistractors: distractorControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        isAutoQuizEnabled: isAutoQuizEnabled,
      );

      if (originalTree != null) {
        await _repo.updateTree(originalTree!.id, request);
      } else {
        await _repo.createTree(request);
      }

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTree() async {
    if (originalTree == null) return;
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repo.deleteTree(originalTree!.id);
      _isSubmitting = false;
      notifyListeners();
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearForm() {
    nameKrController.clear();
    scientificNameController.clear();
    descriptionController.clear();
    _difficulty = 1;
    _selectedCategory = null;
    clearImages();
    clearQuiz();
    notifyListeners();
  }
}
