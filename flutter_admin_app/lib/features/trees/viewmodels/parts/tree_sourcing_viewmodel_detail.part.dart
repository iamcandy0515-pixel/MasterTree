part of '../tree_sourcing_viewmodel.dart';

extension TreeSourcingDetailExtension on TreeSourcingViewModel {
  /// Initialize detail screen data
  Future<void> initDetail(Tree tree) async {
    _selectedTree = tree;
    _isLoading = true;
    _pendingImages.clear();
    _imageSources.clear();
    _fileMissing.clear();
    _hasChanges = false;

    // Rule 1: 화면 진입 시 DB 정보를 기본으로 표시
    for (final img in tree.images) {
      if (img.imageUrl.isNotEmpty) {
        _imageSources['${img.imageType}_original'] = 'db';
      }
      if (img.thumbnailUrl?.isNotEmpty == true) {
        _imageSources['${img.imageType}_thumb'] = 'db';
      }
    }
    notify();

    try {
      // 초기 진입 시에는 isManual: false 로 동기화 (이미 존재하는 URL은 db 배지 유지)
      await syncWithDrive(isManual: false);
      _hasChanges = false; // 초기 로드 후에는 변경사항 없음으로 처리
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
    _fileMissing.clear();
    for (final img in tree.images) {
      if (img.imageUrl.isNotEmpty) {
        _imageSources['${img.imageType}_original'] = 'db';
      }
      if (img.thumbnailUrl != null && img.thumbnailUrl!.isNotEmpty) {
        _imageSources['${img.imageType}_thumb'] = 'db';
      }
    }
    notify();
  }

  void stageImage(
    String type,
    dynamic data, {
    bool isThumbnail = false,
    String source = 'manual',
  }) {
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

  TreeImage? getImageForType(String type) => getImageByType(type);
}
