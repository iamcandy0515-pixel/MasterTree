import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tree.dart';
import '../repositories/tree_repository.dart';

class TreeSourcingViewModel extends ChangeNotifier {
  final _repository = TreeRepository();

  List<Tree> _trees = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMore = true;
  static const int _pageSize = 5;

  List<Tree> get trees => _trees;
  int get currentPage => _currentPage;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  int get totalPages => (_totalCount / _pageSize).ceil();

  Tree? _selectedTree;
  Tree? get selectedTree => _selectedTree;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  // Staging area for locally added images before they are uploaded
  // Key: {type}_{original|thumb}, Value: Uint8List or TreeImage
  final Map<String, dynamic> _pendingImages = {};
  Map<String, dynamic> get pendingImages => _pendingImages;

  // Image Source tracking: 'db', 'google', 'manual'
  final Map<String, String> _imageSources = {};
  Map<String, String> get imageSources => _imageSources;

  // File missing status (for DB URLs that are not in Drive)
  final Map<String, bool> _fileMissing = {};
  Map<String, bool> get fileMissing => _fileMissing;

  String? _driveFolderId;
  String? _thumbFolderId;


  TreeSourcingViewModel() {
    loadTrees();
  }

  Future<void> _loadSettings() async {
    try {
      final driveUrl = await _repository.getGoogleDriveFolderUrl();
      final thumbUrl = await _repository.getThumbnailDriveUrl();

      _driveFolderId = _extractId(driveUrl);
      _thumbFolderId = _extractId(thumbUrl);
    } catch (e) {
      debugPrint('Error loading drive settings: $e');
    }
  }

  String? _extractId(String url) {
    if (url.isEmpty) return null;
    try {
      if (url.contains('id=')) return url.split('id=')[1];
      final parts = url.split('/');
      return parts.where((p) => p.isNotEmpty).last;
    } catch (_) {
      return null;
    }
  }


  Future<void> loadTrees({int page = 1}) async {
    _isLoading = true;
    _currentPage = page;
    _hasChanges = false;
    _pendingImages.clear();
    _imageSources.clear();
    _fileMissing.clear();
    notifyListeners();

    try {
      debugPrint('Fetching trees with query: "$_searchQuery", page: $page');
      final result = await _repository.getTrees(
        page: page,
        limit: _pageSize,
        search: _searchQuery.trim(),
      );

      _trees = result.trees;
      _totalCount = result.total;
      _hasMore = _trees.length >= _pageSize;
      
      debugPrint('Loaded ${_trees.length} trees. Total: $_totalCount');

      if (_trees.isNotEmpty) {
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_hasMore) {
      loadTrees(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadTrees(page: _currentPage - 1);
    }
  }

  /// Initialize detail screen data
  Future<void> initDetail(Tree tree) async {
    _selectedTree = tree;
    _isLoading = true;
    _pendingImages.clear();
    _imageSources.clear();
    _fileMissing.clear();
    notifyListeners();

    try {
      await _loadSettings();

      // 1-1. DB 정보 매핑
      for (final img in tree.images) {
        final type = img.imageType;
        if (img.imageUrl.isNotEmpty) {
          _imageSources['${type}_original'] = 'db';
          // 1-4. 실재 확인
          _checkExistence(img.imageUrl, '${type}_original');
        }
        if (img.thumbnailUrl != null && img.thumbnailUrl!.isNotEmpty) {
          _imageSources['${type}_thumb'] = 'db';
          // 1-4. 실재 확인
          _checkExistence(img.thumbnailUrl!, '${type}_thumb');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkExistence(String url, String key) async {
    if (!url.contains('drive.google.com')) return;
    try {
      final exists = await _repository.checkFileExists(url);
      if (!exists) {
        _fileMissing[key] = true;
        notifyListeners();
      }
    } catch (_) {
      // Handle error silently or log if necessary
    }
  }

  Future<void> generateThumbnailForCategory(String type) async {
    if (_selectedTree == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final thumbUrl = await _repository.generateThumbnail(_selectedTree!.nameKr, type);
      if (thumbUrl != null) {
        final image = TreeImage(
          imageType: type,
          imageUrl: '', // This will be merged
          thumbnailUrl: thumbUrl,
        );
        stageImage(type, image, isThumbnail: true, source: 'google');
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
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
    _imageSources.clear();
    for (final img in tree.images) {
      if (img.imageUrl.isNotEmpty) _imageSources['${img.imageType}_original'] = 'db';
      if (img.thumbnailUrl != null && img.thumbnailUrl!.isNotEmpty) {
        _imageSources['${img.imageType}_thumb'] = 'db';
      }
    }
    notifyListeners();
  }

  void stageImage(String type, dynamic data, {bool isThumbnail = false, String source = 'manual'}) {
    final key = '${type}_${isThumbnail ? 'thumb' : 'original'}';
    _pendingImages[key] = data;
    _imageSources[key] = source;
    _hasChanges = true;
    notifyListeners();
  }

  void removePendingImage(String key) {
    _pendingImages.remove(key);
    // Restore source to DB if it was originally DB
    final type = key.split('_')[0];
    final isThumb = key.split('_')[1] == 'thumb';
    final existing = getImageByType(type);
    
    if (isThumb) {
      if (existing?.thumbnailUrl?.isNotEmpty == true) {
        _imageSources[key] = 'db';
      } else {
        _imageSources.remove(key);
      }
    } else {
      if (existing?.imageUrl.isNotEmpty == true) {
        _imageSources[key] = 'db';
      } else {
        _imageSources.remove(key);
      }
    }

    _hasChanges = _pendingImages.isNotEmpty;
    notifyListeners();
  }

  TreeImage? getImageByType(String type) {
    if (_selectedTree == null) return null;
    try {
      return _selectedTree!.images.firstWhere((img) => img.imageType == type);
    } catch (_) {
      return null;
    }
  }

  Future<void> pickImage(String type, {bool isThumbnail = false}) async {

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      stageImage(type, image, isThumbnail: isThumbnail, source: 'manual');
    }
  }

  Future<void> updateImage(String type, String url) async {
    // This is typically for URL input from dialog
    final image = TreeImage(
      imageType: type,
      imageUrl: url,
    );
    stageImage(type, image, isThumbnail: false, source: 'manual');
  }


  Future<void> saveChanges({Function(String)? onMessage}) async {
    if (_selectedTree == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final List<TreeImage> newImages = [];
      final types = ['main', 'bark', 'leaf', 'flower', 'fruit'];
      
      bool isAnyChange = false;

      for (final type in types) {
        final existing = getImageByType(type);
        
        final stagedOriginal = _pendingImages['${type}_original'];
        final stagedThumb = _pendingImages['${type}_thumb'];

        String? finalUrl = existing?.imageUrl;
        String? finalThumb = existing?.thumbnailUrl;

        // 원본 처리
        if (stagedOriginal != null) {
          if (stagedOriginal is XFile) {
            finalUrl = await _repository.uploadImage(stagedOriginal);
          } else if (stagedOriginal is TreeImage) {
            finalUrl = stagedOriginal.imageUrl;
          } else if (stagedOriginal is Uint8List) {
             final xFile = XFile.fromData(stagedOriginal, name: '${_selectedTree!.nameKr}_${type}_original.jpg');
             finalUrl = await _repository.uploadImage(xFile);
          }
        }

        // 썸네일 처리
        if (stagedThumb != null) {
          if (stagedThumb is XFile) {
            finalThumb = await _repository.uploadImage(stagedThumb);
          } else if (stagedThumb is TreeImage) {
            finalThumb = stagedThumb.thumbnailUrl;
          } else if (stagedThumb is Uint8List) {
             final xFile = XFile.fromData(stagedThumb, name: '${_selectedTree!.nameKr}_${type}_thumb.jpg');
             finalThumb = await _repository.uploadImage(xFile);
          }
        }

        if ((finalUrl != null && finalUrl.isNotEmpty) || (finalThumb != null && finalThumb.isNotEmpty)) {
          newImages.add(TreeImage(
            imageType: type,
            imageUrl: finalUrl ?? '',
            thumbnailUrl: finalThumb,
          ));
        }

        if (finalUrl != existing?.imageUrl || finalThumb != existing?.thumbnailUrl) {
          isAnyChange = true;
        }
      }

      if (!isAnyChange) {
        onMessage?.call('url 정보가 동일하여 db저장을 할수 없다, 확인하세요');
        return;
      }

      await _repository.updateTree(
        _selectedTree!.id,
        CreateTreeRequest(
          nameKr: _selectedTree!.nameKr,
          nameEn: _selectedTree!.nameEn,
          scientificName: _selectedTree!.scientificName,
          description: _selectedTree!.description,
          category: _selectedTree!.category,
          difficulty: _selectedTree!.difficulty,
          images: newImages,
          quizDistractors: _selectedTree!.quizDistractors,
          isAutoQuizEnabled: _selectedTree!.isAutoQuizEnabled,
        ),
      );

      _pendingImages.clear();
      _hasChanges = false;
      onMessage?.call('저장 완료');
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

  Future<void> fetchFromDrive() async {
    await fetchGoogleImagesAll();
  }


}
