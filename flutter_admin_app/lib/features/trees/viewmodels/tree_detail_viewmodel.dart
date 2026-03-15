import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_repository.dart';

class TreeDetailViewModel extends ChangeNotifier {
  final MasterTreeRepository _repository = MasterTreeRepository();
  final Tree tree;

  // Controllers
  final TextEditingController nameKrController;
  final TextEditingController scientificNameController;
  final TextEditingController descController;
  final TextEditingController itemDescController;

  int _maxDistractors = 2;
  String _treeCategory = '침엽수';
  String _foliageType = '상록수';
  List<String> _distractors = [];
  bool _isAutoQuizEnabled = true;

  // Map to store images for each category: 'main', 'leaf', 'bark', 'flower', 'fruit', 'winterBud'
  final Map<String, TreeImage> _categoryImages = {};
  // Map to store hint texts for each category
  final Map<String, String> _categoryHints = {};

  bool _isSaving = false;
  bool _hasSaved = false;
  String? _errorMessage;
  bool _isUploadingImage = false;
  String? _currentUploadingCategory; // Track which category is uploading

  TreeDetailViewModel({required this.tree})
    : nameKrController = TextEditingController(text: tree.nameKr),
      scientificNameController = TextEditingController(
        text: tree.scientificName,
      ),
      descController = TextEditingController(text: tree.description),
      itemDescController = TextEditingController() {
    _initialize();
  }

  // Getters
  String get treeCategory => _treeCategory;
  String get foliageType => _foliageType;
  int get maxDistractors => _maxDistractors;
  List<String> get distractors => _distractors;
  bool get isAutoQuizEnabled => _isAutoQuizEnabled;
  bool get isSaving => _isSaving;
  bool get hasSaved => _hasSaved;
  String? get errorMessage => _errorMessage;
  bool get isUploadingImage => _isUploadingImage;
  String? get currentUploadingCategory => _currentUploadingCategory;

  TreeImage? getCategoryImage(String type) => _categoryImages[type];
  String getCategoryHint(String type) => _categoryHints[type] ?? '';
  String? get currentImageUrl =>
      _categoryImages['main']?.imageUrl ?? tree.imageUrl;

  void _initialize() {
    if (tree.category != null) {
      if (tree.category!.contains('활엽수')) {
        _treeCategory = '활엽수';
      } else {
        _treeCategory = '침엽수';
      }

      if (tree.category!.contains('낙엽수')) {
        _foliageType = '낙엽수';
      } else {
        _foliageType = '상록수';
      }
    }
    _distractors = List.from(tree.quizDistractors);
    _isAutoQuizEnabled = tree.isAutoQuizEnabled;

    // Initialize category images and hints from tree data
    for (var image in tree.images) {
      _categoryImages[image.imageType] = image;
      if (image.hint != null) {
        _categoryHints[image.imageType] = image.hint!;
      }
    }

    // Set initial hint for 'leaf' as default for itemDescController
    itemDescController.text = _categoryHints['leaf'] ?? '';
  }

  // Update itemDescController when switching category in UI
  void syncHintController(String categoryType) {
    itemDescController.text = _categoryHints[categoryType] ?? '';
  }

  // Update hint in map whenever text changes
  void updateHint(String categoryType, String hint) {
    _categoryHints[categoryType] = hint;
  }

  Future<void> pickAndUploadCategoryImage(String categoryType) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    _isUploadingImage = true;
    _currentUploadingCategory = categoryType;
    _errorMessage = null;
    notifyListeners();

    try {
      final publicUrl = await _repository.uploadImage(image);
      _categoryImages[categoryType] = TreeImage(
        imageType: categoryType,
        imageUrl: publicUrl,
        isQuizEnabled: true,
        hint: _categoryHints[categoryType],
      );
      _isUploadingImage = false;
      _currentUploadingCategory = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = '이미지 업로드 실패: $e';
      _isUploadingImage = false;
      _currentUploadingCategory = null;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadImage() => pickAndUploadCategoryImage('main');

  void setTreeCategory(String value) {
    _treeCategory = value;
    notifyListeners();
  }

  void setFoliageType(String value) {
    _foliageType = value;
    notifyListeners();
  }

  void toggleAutoQuiz() {
    _isAutoQuizEnabled = !_isAutoQuizEnabled;
    notifyListeners();
  }

  void setMaxDistractors(int value) {
    _maxDistractors = value;
    notifyListeners();
  }

  Future<void> addDistractor() async {
    if (_isAutoQuizEnabled) {
      try {
        final randomTrees = await _repository.getRandomTrees(
          count: 1,
          category: _treeCategory,
          excludeName: tree.nameKr,
        );

        if (randomTrees.isNotEmpty) {
          _distractors.add(randomTrees.first);
        } else {
          _distractors.add('추천 수목 없음');
        }
      } catch (e) {
        _distractors.add('데이터 로드 실패');
      }
    } else {
      _distractors.add('');
    }
    notifyListeners();
  }

  void clearDistractors() {
    _distractors.clear();
    notifyListeners();
  }

  void updateDistractor(int index, String value) {
    if (index >= 0 && index < _distractors.length) {
      _distractors[index] = value;
    }
  }

  void removeDistractor(int index) {
    if (index >= 0 && index < _distractors.length) {
      _distractors.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> saveTree() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, TreeImage> finalImagesMap = {};

      for (var img in tree.images) {
        finalImagesMap[img.imageType] = img;
      }

      _categoryImages.forEach((type, img) {
        finalImagesMap[type] = img.copyWith(hint: _categoryHints[type]);
      });

      _categoryHints.forEach((type, hint) {
        if (finalImagesMap.containsKey(type)) {
          finalImagesMap[type] = finalImagesMap[type]!.copyWith(hint: hint);
        }
      });

      final finalCategory = '$_treeCategory / $_foliageType';

      final request = CreateTreeRequest(
        nameKr: nameKrController.text,
        scientificName: scientificNameController.text,
        description: descController.text,
        category: finalCategory,
        difficulty: tree.difficulty,
        images: finalImagesMap.values.toList(),
        quizDistractors: _distractors,
        isAutoQuizEnabled: _isAutoQuizEnabled,
      );

      await _repository.updateTree(tree.id, request);
      _hasSaved = true;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '저장 실패: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameKrController.dispose();
    scientificNameController.dispose();
    descController.dispose();
    itemDescController.dispose();
    super.dispose();
  }
}
