import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tree.dart';
import '../repositories/tree_repository.dart';

class TreeSourcingViewModel extends ChangeNotifier {
  final _repository = TreeRepository();

  List<Tree> _trees = [];
  List<Tree> get trees => _trees;

  Tree? _selectedTree;
  Tree? get selectedTree => _selectedTree;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  // Staging area for locally added images before they are uploaded
  final Map<String, Uint8List> _pendingImages = {};
  Map<String, Uint8List> get pendingImages => _pendingImages;

  TreeSourcingViewModel() {
    loadTrees();
  }

  Future<void> loadTrees() async {
    _isLoading = true;
    _hasChanges = false;
    _pendingImages.clear();
    notifyListeners();

    try {
      debugPrint('Fetching trees with query: "$_searchQuery"');
      final result = await _repository.getTrees(
        page: 1,
        limit: 10,
        search: _searchQuery.trim(),
        // If sorting or category filtering becomes an issue, ensure defaults here
      );

      _trees = result.trees;
      debugPrint('Loaded ${_trees.length} trees.');

      if (_trees.isNotEmpty) {
        // Keep current selection if valid, otherwise select first
        if (_selectedTree == null ||
            !_trees.any((t) => t.id == _selectedTree!.id)) {
          _selectedTree = _trees.first;
        }
      } else {
        _selectedTree = null;
      }
    } catch (e) {
      debugPrint('Error loading trees in TreeSourcingViewModel: $e');
      _selectedTree = null;
      // Consider exposing error message to UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> aiSearch() async {
    if (_selectedTree == null) {
      throw '먼저 수목을 조회해주세요.';
    }

    _isLoading = true;
    _hasChanges = false;
    _pendingImages.clear();
    _searchQuery = '';
    notifyListeners();

    try {
      String categoryFilter = '';
      if (_selectedTree != null) {
        final currentCategory = _selectedTree!.category ?? '';

        // 1. Determine Leaf Type (Needle vs Broad)
        String leafType = '';
        if (currentCategory.contains('침엽')) {
          leafType = '침엽';
        } else if (currentCategory.contains('활엽')) {
          leafType = '활엽';
        }

        // 2. Determine Retention Type (Evergreen vs Deciduous)
        String retentionType = '';
        if (currentCategory.contains('상록')) {
          retentionType = '상록';
        } else if (currentCategory.contains('낙엽')) {
          retentionType = '낙엽';
        }

        // Combine for strict filtering: e.g. "상록,침엽" matches trees with both tags
        final List<String> tags = [];
        if (retentionType.isNotEmpty) tags.add(retentionType);
        if (leafType.isNotEmpty) tags.add(leafType);

        categoryFilter = tags.join(',');
      }

      final names = await _repository.getRandomTrees(
        count: 1,
        category: categoryFilter.isNotEmpty ? categoryFilter : null,
        excludeName: _selectedTree!.nameKr,
      );

      if (names.isNotEmpty) {
        final result = await _repository.getTrees(
          page: 1,
          limit: 1,
          search: names.first,
        );
        if (result.trees.isNotEmpty) {
          _trees = [result.trees.first];
          _selectedTree = _trees.first;
        }
      } else {
        throw '조건에 맞는 추천 수목이 없습니다.';
      }
    } catch (e) {
      debugPrint('Error in AI Search: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
  }

  void selectTree(Tree tree) {
    _selectedTree = tree;
    _hasChanges = false;
    _pendingImages.clear();
    notifyListeners();
  }

  void stageImage(String type, Uint8List bytes) {
    _pendingImages[type] = bytes;
    _hasChanges = true;
    notifyListeners();
  }

  Future<void> updateImage(String type, String url) async {
    if (_selectedTree == null) return;

    final updatedImages = List<TreeImage>.from(_selectedTree!.images);
    final index = updatedImages.indexWhere((img) => img.imageType == type);

    if (index >= 0) {
      updatedImages[index] = updatedImages[index].copyWith(imageUrl: url);
    } else {
      updatedImages.add(TreeImage(imageType: type, imageUrl: url));
    }

    _selectedTree = _selectedTree!.copyWith(images: updatedImages);
    _hasChanges = true;
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (_selectedTree == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Upload pending binary images first
      final List<TreeImage> updatedImages = List.from(_selectedTree!.images);

      for (final entry in _pendingImages.entries) {
        final type = entry.key;
        final bytes = entry.value;

        // Create XFile from bytes using cross_file format if possible or just use a helper
        // Since TreeRepository.uploadImage expects XFile, we'll convert it.
        // On web, XFile.fromData works fine.
        final xFile = XFile.fromData(
          bytes,
          name: '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        final publicUrl = await _repository.uploadImage(xFile);

        final index = updatedImages.indexWhere((img) => img.imageType == type);
        if (index >= 0) {
          updatedImages[index] = updatedImages[index].copyWith(
            imageUrl: publicUrl,
          );
        } else {
          updatedImages.add(TreeImage(imageType: type, imageUrl: publicUrl));
        }
      }

      // 2. Update tree with all new URLs
      _selectedTree = _selectedTree!.copyWith(images: updatedImages);

      await _repository.updateTree(
        _selectedTree!.id,
        CreateTreeRequest(
          nameKr: _selectedTree!.nameKr,
          nameEn: _selectedTree!.nameEn,
          scientificName: _selectedTree!.scientificName,
          description: _selectedTree!.description,
          category: _selectedTree!.category,
          difficulty: _selectedTree!.difficulty,
          images: _selectedTree!.images,
          quizDistractors: _selectedTree!.quizDistractors,
          isAutoQuizEnabled: _selectedTree!.isAutoQuizEnabled,
        ),
      );

      _pendingImages.clear();
      _hasChanges = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving tree changes: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  TreeImage? getImageForType(String type) {
    if (_selectedTree == null) return null;
    try {
      return _selectedTree!.images.firstWhere((img) => img.imageType == type);
    } catch (_) {
      return null;
    }
  }

  Future<int> fetchGoogleImagesAll() async {
    if (_selectedTree == null) return 0;

    _isLoading = true;
    notifyListeners();

    try {
      final types = ['main', 'leaf', 'bark', 'fruit', 'flower'];
      final results = await Future.wait(
        types.map((type) => _fetchGoogleImage(type)),
      );
      return results.where((success) => success).length;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _fetchGoogleImage(String type) async {
    if (_selectedTree == null) return false;

    try {
      final imageBytes = await _repository.downloadGoogleImage(
        _selectedTree!.nameKr,
        type,
      );

      if (imageBytes != null && imageBytes.isNotEmpty) {
        stageImage(type, imageBytes);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching google image for $type: $e');
      return false;
    }
  }
}
