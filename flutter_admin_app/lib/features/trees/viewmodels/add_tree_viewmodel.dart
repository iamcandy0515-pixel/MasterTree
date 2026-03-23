import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/core/utils/web_utils.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_repository.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_media_repository.dart';

class AddTreeViewModel extends ChangeNotifier {
  final MasterTreeRepository _repo = MasterTreeRepository();
  final MasterTreeMediaRepository _mediaRepo = MasterTreeMediaRepository();

  final Tree? originalTree;

  // Form Fields
  final TextEditingController nameKrController = TextEditingController();
  final TextEditingController scientificNameController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? _selectedCategory;
  int _difficulty = 1;

  // Images
  final List<TreeImage> _uploadedImages = [];
  bool _isUploading = false;
  bool _isSubmitting = false;
  String _selectedImageType = 'main';

  // Quiz Distractors
  final List<TextEditingController> distractorControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isAutoQuizEnabled = true;
  String? _errorMessage;

  // Getters
  String? get selectedCategory => _selectedCategory;
  int get difficulty => _difficulty;
  List<TreeImage> get uploadedImages => _uploadedImages;
  bool get isUploading => _isUploading;
  bool get isSubmitting => _isSubmitting;
  String get selectedImageType => _selectedImageType;
  bool get isAutoQuizEnabled => _isAutoQuizEnabled;
  String? get errorMessage => _errorMessage;

  AddTreeViewModel(this.originalTree) {
    if (originalTree != null) {
      nameKrController.text = originalTree!.nameKr;
      scientificNameController.text = originalTree!.scientificName ?? '';
      descriptionController.text = originalTree!.description ?? '';
      _selectedCategory = originalTree!.category;
      _difficulty = originalTree!.difficulty;
      _uploadedImages.addAll(originalTree!.images);

      // Load Quiz Distractors
      if (originalTree!.quizDistractors.isNotEmpty) {
        distractorControllers.clear();
        for (var distractor in originalTree!.quizDistractors) {
          distractorControllers.add(TextEditingController(text: distractor));
        }
      }
      _isAutoQuizEnabled = originalTree!.isAutoQuizEnabled;
    }
  }

  @override
  void dispose() {
    nameKrController.dispose();
    scientificNameController.dispose();
    descriptionController.dispose();
    for (var controller in distractorControllers) {
      controller.dispose();
    }
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

  void setSelectedImageType(String value) {
    _selectedImageType = value;
    notifyListeners();
  }

  void removeImage(int index) {
    _uploadedImages.removeAt(index);
    notifyListeners();
  }

  // Quiz Distractor Methods
  void addDistractor() {
    distractorControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeDistractor(int index) {
    if (distractorControllers.length > 1) {
      distractorControllers[index].dispose();
      distractorControllers.removeAt(index);
      notifyListeners();
    }
  }

  void setAutoQuizEnabled(bool value) {
    _isAutoQuizEnabled = value;
    notifyListeners();
  }

  Future<void> handleDroppedFiles(dynamic file) async {
    try {
      _isUploading = true;
      notifyListeners();

      final bytes = await WebUtils.readFileAsBytes(file);
      if (bytes == null) throw Exception('파일을 읽을 수 없습니다.');

      final xFile = XFile.fromData(
        Uint8List.fromList(bytes),
        name: kIsWeb ? (file as dynamic).name : 'dropped_file',
        mimeType: kIsWeb ? (file as dynamic).type : 'image/jpeg',
      );
      final publicUrl = await _mediaRepo.uploadImage(xFile);

      _uploadedImages.add(
        TreeImage(imageType: _selectedImageType, imageUrl: publicUrl),
      );
      _isUploading = false;
      notifyListeners();
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) return;

      _isUploading = true;
      notifyListeners();

      final xFile = XFile.fromData(
        file.bytes!,
        name: file.name,
        mimeType: 'image/${file.extension}',
      );

      final publicUrl = await _mediaRepo.uploadImage(xFile);

      _uploadedImages.add(
        TreeImage(imageType: _selectedImageType, imageUrl: publicUrl),
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
    if (!kIsWeb) {
      throw Exception('모바일에서는 클립보드 붙여넣기가 지원되지 않습니다.');
    }

    try {
      _isUploading = true;
      _errorMessage = null; // Clear previous error
      notifyListeners();

      bool imageFound = false;
      await WebUtils.pasteImageFromClipboard((bytes, name, type) async {
        final xFile = XFile.fromData(
          Uint8List.fromList(bytes),
          name: name,
          mimeType: type,
        );

        final publicUrl = await _mediaRepo.uploadImage(xFile);
        _uploadedImages.add(
          TreeImage(imageType: _selectedImageType, imageUrl: publicUrl),
        );
        imageFound = true;
      });

      _isUploading = false;
      notifyListeners();
      if (!imageFound) throw Exception('클립보드에 이미지가 없습니다.');
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> submitTree() async {
    if (_uploadedImages.isEmpty) {
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
        images: _uploadedImages,
        quizDistractors: distractorControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        isAutoQuizEnabled: _isAutoQuizEnabled,
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
    _uploadedImages.clear();
    _selectedImageType = 'main';
    for (var controller in distractorControllers) {
      controller.clear();
    }
    notifyListeners();
  }
}
