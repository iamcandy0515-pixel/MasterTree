import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/tree_registration/models/tree_registration_request.dart';
import 'package:flutter_admin_app/features/tree_registration/repositories/tree_registration_repository.dart';

class TreeRegistrationViewModel extends ChangeNotifier {
  final TreeRegistrationRepository _repo = TreeRegistrationRepository();

  // Form Fields
  final TextEditingController nameKrController = TextEditingController();
  final TextEditingController scientificNameController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? _selectedHabit; // 상록수, 낙엽수
  String? _selectedCategory; // 침엽수, 활엽수

  // Images & Hints (Tagged Management)
  final Map<String, TreeImage> _taggedImages = {};

  // Current UI State
  String _activeTag = 'main'; // 'main' | 'leaf' | 'bark' | 'flower' | 'fruit'
  bool _isUploading = false;
  bool _isSubmitting = false;

  // Quiz Distractors (Fixed 2)
  final List<TextEditingController> distractorControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  // Getters
  String? get selectedHabit => _selectedHabit;
  String? get selectedCategory => _selectedCategory;
  String get activeTag => _activeTag;
  bool get isUploading => _isUploading;
  bool get isSubmitting => _isSubmitting;
  Map<String, TreeImage> get taggedImages => _taggedImages;

  @override
  void dispose() {
    nameKrController.dispose();
    scientificNameController.dispose();
    descriptionController.dispose();
    for (var c in distractorControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void setSelectedHabit(String? value) {
    _selectedHabit = value;
    notifyListeners();
  }

  void setSelectedCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setActiveTag(String tag) {
    _activeTag = tag;
    notifyListeners();
  }

  void updateHint(String type, String hint) {
    if (_taggedImages.containsKey(type)) {
      _taggedImages[type] = _taggedImages[type]!.copyWith(hint: hint);
      notifyListeners();
    }
  }

  void removeImage(String type) {
    _taggedImages.remove(type);
    notifyListeners();
  }

  Future<void> handleImageUpload(XFile xFile) async {
    try {
      _isUploading = true;
      notifyListeners();

      final publicUrl = await _repo.uploadImage(xFile);

      _taggedImages[_activeTag] = TreeImage(
        imageType: _activeTag,
        imageUrl: publicUrl,
        hint: '',
      );

      _isUploading = false;
      notifyListeners();
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pasteImageFromClipboard() async {
    // Disabled temporarily
    debugPrint('Clipboard paste is temporarily disabled');
  }

  Future<void> searchGoogleImage() async {
    final treeName = nameKrController.text.trim();
    if (treeName.isEmpty) throw Exception('수목명을 먼저 입력해주세요.');

    try {
      _isUploading = true;
      notifyListeners();

      // 구글 이미지는 B 방식 (다운로드 후 스토리지 업로드)
      final url = await _repo.searchAndAttachGoogleImage(treeName, _activeTag);
      if (url != null) {
        _taggedImages[_activeTag] = TreeImage(
          imageType: _activeTag,
          imageUrl: url,
          hint: '',
        );
      } else {
        throw Exception('검색된 이미지가 없습니다.');
      }

      _isUploading = false;
      notifyListeners();
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submit() async {
    if (nameKrController.text.trim().isEmpty) throw Exception('수목명을 입력해주세요.');
    if (_selectedCategory == null) throw Exception('구분을 선택해주세요.');
    if (_selectedHabit == null) throw Exception('성상을 선택해주세요.');
    if (!_taggedImages.containsKey('main'))
      throw Exception('최소한 "대표" 이미지는 등록해야 합니다.');

    _isSubmitting = true;
    notifyListeners();

    try {
      final request = TreeRegistrationRequest(
        nameKr: nameKrController.text.trim(),
        scientificName: scientificNameController.text.trim(),
        description: descriptionController.text.trim(),
        category: '$_selectedCategory,$_selectedHabit',
        habit: _selectedHabit!,
        images: _taggedImages.values.toList(),
        quizDistractors: distractorControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        isAutoQuizEnabled: true,
      );

      await _repo.registerTree(request);

      _isSubmitting = false;
      notifyListeners();
      clearForm();
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
    _selectedCategory = null;
    _selectedHabit = null;
    _taggedImages.clear();
    _activeTag = 'main';
    for (var c in distractorControllers) {
      c.clear();
    }
    notifyListeners();
  }
}
