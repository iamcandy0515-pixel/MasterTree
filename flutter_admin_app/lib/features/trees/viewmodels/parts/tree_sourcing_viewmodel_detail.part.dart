part of '../tree_sourcing_viewmodel.dart';

extension TreeSourcingDetailExtension on TreeSourcingViewModel {
  /// Initialize detail screen data
  Future<void> initDetail(Tree tree) async {
    _selectedTree = tree;
    _isLoading = true;
    _pendingImages.clear();
    _imageSources.clear();
    _fileMissing.clear();
    notify();

    try {
      await syncWithDrive();
    } finally {
      _isLoading = false;
      notify();
    }
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
    notify();
  }

  void stageImage(String type, dynamic data, {bool isThumbnail = false, String source = 'manual'}) {
    final key = '${type}_${isThumbnail ? 'thumb' : 'original'}';
    _pendingImages[key] = data;
    _imageSources[key] = source;
    _hasChanges = true;
    notify();
  }

  void removePendingImage(String key) {
    _pendingImages.remove(key);
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
    notify();
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
    final image = TreeImage(imageType: type, imageUrl: url);
    stageImage(type, image, isThumbnail: false, source: 'manual');
  }

  Future<void> saveChanges({Function(String)? onMessage}) async {
    if (_selectedTree == null) return;

    _isLoading = true;
    notify();

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

        if (stagedOriginal != null) {
          if (stagedOriginal is XFile) {
            finalUrl = await _repository.uploadImage(stagedOriginal);
          } else if (stagedOriginal is TreeImage) {
            finalUrl = stagedOriginal.imageUrl;
          }
          else if (stagedOriginal is Uint8List) {
             final xFile = XFile.fromData(stagedOriginal, name: '${_selectedTree!.nameKr}_${type}_original.jpg');
             finalUrl = await _repository.uploadImage(xFile);
          }
        }

        if (stagedThumb != null) {
          if (stagedThumb is XFile) {
            finalThumb = await _repository.uploadImage(stagedThumb);
          } else if (stagedThumb is TreeImage) {
            finalThumb = stagedThumb.thumbnailUrl;
          }
          else if (stagedThumb is Uint8List) {
             final xFile = XFile.fromData(stagedThumb, name: '${_selectedTree!.nameKr}_${type}_thumb.jpg');
             finalThumb = await _repository.uploadImage(xFile);
          }
        }

        if ((finalUrl != null && finalUrl.isNotEmpty) || (finalThumb != null && finalThumb.isNotEmpty)) {
          newImages.add(TreeImage(imageType: type, imageUrl: finalUrl ?? '', thumbnailUrl: finalThumb));
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
          nameKr: _selectedTree!.nameKr, nameEn: _selectedTree!.nameEn,
          scientificName: _selectedTree!.scientificName, description: _selectedTree!.description,
          category: _selectedTree!.category, difficulty: _selectedTree!.difficulty,
          images: newImages, quizDistractors: _selectedTree!.quizDistractors,
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
      notify();
    }
  }

  TreeImage? getImageForType(String type) => getImageByType(type);
}
