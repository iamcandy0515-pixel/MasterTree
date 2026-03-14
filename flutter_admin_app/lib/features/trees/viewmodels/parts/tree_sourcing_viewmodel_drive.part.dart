part of '../tree_sourcing_viewmodel.dart';

extension TreeSourcingDriveExtension on TreeSourcingViewModel {
  Future<void> _checkExistence(String url, String key) async {
    if (!url.contains('drive.google.com')) return;
    try {
      final exists = await _repository.checkFileExists(url);
      if (!exists) {
        _fileMissing[key] = true;
        notify();
      }
    } catch (_) {
      // Handle error silently
    }
  }

  Future<void> generateThumbnailForCategory(String type) async {
    if (_selectedTree == null) return;

    _isLoading = true;
    notify();

    try {
      final thumbUrl = await _repository.generateThumbnail(
        _selectedTree!.nameKr,
        type,
      );
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
      notify();
    }
  }

  Future<void> fetchGoogleImagesAll() async {
    if (_selectedTree == null) return;
    await syncWithDrive();
  }

  Future<void> syncWithDrive() async {
    if (_selectedTree == null) return;

    _isLoading = true;
    notify();

    try {
      final result = await _repository.getDriveLinks(_selectedTree!.nameKr);
      if (result['success'] == true) {
        final Map<String, dynamic> original = result['original'] ?? {};
        final Map<String, dynamic> thumb = result['thumb'] ?? {};

        final types = ['main', 'leaf', 'bark', 'fruit', 'flower'];

        for (final type in types) {
          final dbImage = getImageByType(type);

          // Original Link Sync
          final driveOriginalUrl = original[type];
          if (driveOriginalUrl != null) {
            _fileMissing.remove('${type}_original');
            // Drive에서 정보가 발견되면 박스와 URL 설정에 매치 (구글 정보 배지 포함)
            if (dbImage == null || dbImage.imageUrl != driveOriginalUrl) {
              stageImage(
                type,
                TreeImage(
                  imageType: type,
                  imageUrl: driveOriginalUrl,
                  thumbnailUrl: dbImage?.thumbnailUrl,
                ),
                source: 'google',
              );
            }
          } else if (dbImage != null && dbImage.imageUrl.isNotEmpty) {
            _checkExistence(dbImage.imageUrl, '${type}_original');
          }

          // Thumbnail Link Sync
          final driveThumbUrl = thumb[type];
          if (driveThumbUrl != null) {
            _fileMissing.remove('${type}_thumb');
            // Drive에서 썸네일 정보가 발견되면 박스와 URL 설정에 매치 (구글 정보 배지 포함)
            if (dbImage == null || dbImage.thumbnailUrl != driveThumbUrl) {
              final currentStaged =
                  _pendingImages['${type}_original'] as TreeImage?;
              stageImage(
                type,
                TreeImage(
                  imageType: type,
                  imageUrl: currentStaged?.imageUrl ?? dbImage?.imageUrl ?? '',
                  thumbnailUrl: driveThumbUrl,
                ),
                isThumbnail: true,
                source: 'google',
              );
            }
          } else if (dbImage != null &&
              dbImage.thumbnailUrl != null &&
              dbImage.thumbnailUrl!.isNotEmpty) {
            _checkExistence(dbImage.thumbnailUrl!, '${type}_thumb');
          }
        }
      }
    } catch (e) {
      debugPrint('Error syncing with Drive: $e');
    } finally {
      _isLoading = false;
      notify();
    }
  }

  Future<void> fetchFromDrive() async {
    await syncWithDrive();
  }

  Future<void> aiSearch() async {
    if (_selectedTree == null) {
      throw '먼저 수목을 조회해주세요.';
    }

    _isLoading = true;
    _hasChanges = false;
    _pendingImages.clear();
    _searchQuery = '';
    notify();

    try {
      String categoryFilter = '';
      if (_selectedTree != null) {
        final currentCategory = _selectedTree!.category ?? '';

        String leafType = '';
        if (currentCategory.contains('침엽')) {
          leafType = '침엽';
        } else if (currentCategory.contains('활엽')) {
          leafType = '활엽';
        }

        String retentionType = '';
        if (currentCategory.contains('상록')) {
          retentionType = '상록';
        } else if (currentCategory.contains('낙엽')) {
          retentionType = '낙엽';
        }

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
      notify();
    }
  }
}
