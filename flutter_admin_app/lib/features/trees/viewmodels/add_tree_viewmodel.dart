import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/models/create_tree_request.dart';
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
  bool _isSearching = false; // T-1: 검색 상태 추가
  String? _errorMessage;

  // Getters
  String? get selectedCategory => _selectedCategory;
  int get difficulty => _difficulty;
  bool get isSubmitting => _isSubmitting;
  bool get isSearching => _isSearching; // T-1: 검색 상태 Getter
  String? get errorMessage => _errorMessage;

  /// T-2: 수목명으로 기존 정보 조회
  Future<void> searchTreeByName() async {
    final name = nameKrController.text.trim();
    if (name.isEmpty) return;

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // minimal: false를 통해 전체 상세 정보를 가져옴
      final result = await _repo.getTrees(search: name, minimal: false);
      
      if (result.trees.isNotEmpty) {
        // 가장 유사한 첫 번째 결과 사용 (승인된 답변 2번: 즉시 덮어쓰기)
        final tree = result.trees.first;
        scientificNameController.text = tree.scientificName ?? '';
        descriptionController.text = tree.description ?? '';
        _selectedCategory = tree.category;
        _difficulty = tree.difficulty;
        
        // 이미지 및 퀴즈 정보 초기화 (기존 정보 활용 시 대비)
        initializeImages(tree.images);
        initializeQuiz(tree.quizDistractors, tree.isAutoQuizEnabled);
        
        _errorMessage = "기존 등록된 '${tree.nameKr}' 정보를 불러왔습니다.";
      } else {
        _errorMessage = "'$name'으로 등록된 수목 정보가 없습니다.";
      }
    } catch (e) {
      _errorMessage = "조회 실패: ${e.toString()}";
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

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
