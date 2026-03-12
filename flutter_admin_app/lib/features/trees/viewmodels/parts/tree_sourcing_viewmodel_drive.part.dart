part of '../tree_sourcing_viewmodel.dart';

extension TreeSourcingDriveExtension on TreeSourcingViewModel {
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
            if (dbImage == null || dbImage.imageUrl.isEmpty) {
              // DB is empty, fill from Drive
              stageImage(type, TreeImage(imageType: type, imageUrl: driveOriginalUrl), source: 'google');
            } else if (dbImage.imageUrl == driveOriginalUrl) {
              // DB exists, but let's check if it exists in drive really (usually yes if it's in the list)
              _fileMissing.remove('${type}_original');
            } else {
              // DB exists but different? User might want to overwrite manually if needed, 
              // but for now we just mark existence for the DB URL
              _checkExistence(dbImage.imageUrl, '${type}_original');
            }
          } else if (dbImage != null && dbImage.imageUrl.isNotEmpty) {
             // DB has URL but not found in Drive list
             _fileMissing['${type}_original'] = true;
          }

          // Thumbnail Link Sync
          final driveThumbUrl = thumb[type];
          if (driveThumbUrl != null) {
            if (dbImage == null || dbImage.thumbnailUrl == null || dbImage.thumbnailUrl!.isEmpty) {
              // Stage it
              final currentStaged = _pendingImages['${type}_original'] as TreeImage?;
              stageImage(type, TreeImage(
                imageType: type, 
                imageUrl: currentStaged?.imageUrl ?? dbImage?.imageUrl ?? '',
                thumbnailUrl: driveThumbUrl
              ), isThumbnail: true, source: 'google');
            } else if (dbImage.thumbnailUrl == driveThumbUrl) {
              _fileMissing.remove('${type}_thumb');
            } else {
              _checkExistence(dbImage.thumbnailUrl!, '${type}_thumb');
            }
          } else if (dbImage != null && dbImage.thumbnailUrl != null && dbImage.thumbnailUrl!.isNotEmpty) {
             _fileMissing['${type}_thumb'] = true;
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
