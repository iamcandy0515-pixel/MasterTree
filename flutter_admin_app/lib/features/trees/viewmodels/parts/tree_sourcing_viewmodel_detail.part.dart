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

  Future<void> saveChanges({Function(String)? onMessage}) async {
    if (_selectedTree == null) return;

    _isLoading = true;
    notify();

    try {
      final List<TreeImage> newImages = [];
      final types = ['main', 'bark', 'leaf', 'flower', 'fruit'];
      bool isAnyChange = false;

      // URL 형식 검사 함수
      bool isValidDriveUrl(String url) {
        if (url.isEmpty) return true; // 비어있는 경우는 삭제로 간주, 형식 통과
        return url.contains('https://drive.google.com/uc?export=view&id=');
      }

      for (final type in types) {
        final existing = getImageByType(type);
        final stagedOriginal = _pendingImages['${type}_original'];
        final stagedThumb = _pendingImages['${type}_thumb'];

        String? finalUrl = existing?.imageUrl;
        String? finalThumb = existing?.thumbnailUrl;

        if (stagedOriginal != null) {
          if (stagedOriginal is XFile) {
            finalUrl = await _mediaRepo.uploadImage(stagedOriginal);
          } else if (stagedOriginal is TreeImage) {
            finalUrl = stagedOriginal.imageUrl;
          } else if (stagedOriginal is Uint8List) {
            finalUrl = await _mediaRepo.uploadImageFromBytes(
              stagedOriginal,
              '${_selectedTree!.nameKr}_${type}_original.jpg',
            );
          }
        }

        if (stagedThumb != null) {
          if (stagedThumb is XFile) {
            finalThumb = await _mediaRepo.uploadImage(stagedThumb);
          } else if (stagedThumb is TreeImage) {
            finalThumb = stagedThumb.thumbnailUrl;
          } else if (stagedThumb is Uint8List) {
            finalThumb = await _mediaRepo.uploadImageFromBytes(
              stagedThumb,
              '${_selectedTree!.nameKr}_${type}_thumb.jpg',
            );
          }
        }

        // URL 유효성 검사 (입력된 URL이 구글 드라이브 형식인지 확인)
        if (finalUrl != null &&
            !isValidDriveUrl(finalUrl) &&
            !finalUrl.contains('supabase.co')) {
          onMessage?.call('원본 이미지 URL 형식이 올바르지 않습니다. 구글 드라이브 URL인지 확인하세요.');
          return;
        }
        if (finalThumb != null &&
            !isValidDriveUrl(finalThumb) &&
            !finalThumb.contains('supabase.co')) {
          onMessage?.call('썸네일 이미지 URL 형식이 올바르지 않습니다. 구글 드라이브 URL인지 확인하세요.');
          return;
        }

        if ((finalUrl != null && finalUrl.isNotEmpty) ||
            (finalThumb != null && finalThumb.isNotEmpty)) {
          newImages.add(
            TreeImage(
              imageType: type,
              imageUrl: finalUrl ?? '',
              thumbnailUrl: finalThumb,
            ),
          );
        }

        if (finalUrl != existing?.imageUrl ||
            finalThumb != existing?.thumbnailUrl) {
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
      notify();
    }
  }

  TreeImage? getImageForType(String type) => getImageByType(type);
}
