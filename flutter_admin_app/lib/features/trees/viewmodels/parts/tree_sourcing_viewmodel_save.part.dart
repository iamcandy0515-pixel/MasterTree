part of '../tree_sourcing_viewmodel.dart';

extension TreeSourcingSaveExtension on TreeSourcingViewModel {
  /// Save all pending changes to the database
  Future<void> saveChanges({Function(String)? onMessage}) async {
    if (_selectedTree == null) return;

    _isLoading = true;
    notify();

    try {
      final List<TreeImage> newImages = [];
      final types = ['main', 'bark', 'leaf', 'flower', 'fruit'];
      bool isAnyChange = false;

      // URL 형식 검사 함수 (구글 드라이브 형식 준수 여부)
      bool isValidDriveUrl(String url) {
        if (url.isEmpty) return true; // 비어있는 경우는 삭제로 간주
        return url.contains('https://drive.google.com/uc?export=view&id=');
      }

      for (final type in types) {
        final existing = getImageByType(type);
        final stagedOriginal = _pendingImages['${type}_original'];
        final stagedThumb = _pendingImages['${type}_thumb'];

        String? finalUrl = existing?.imageUrl;
        String? finalThumb = existing?.thumbnailUrl;

        // 원본 이미지 처리
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

        // 썸네일 이미지 처리
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

        // URL 유효성 검사 (드라이브 또는 Supabase 허용)
        if (finalUrl != null &&
            !isValidDriveUrl(finalUrl) &&
            !finalUrl.contains('supabase.co')) {
          onMessage?.call('원본 이미지 URL 형식이 올바르지 않습니다.');
          return;
        }
        if (finalThumb != null &&
            !isValidDriveUrl(finalThumb) &&
            !finalThumb.contains('supabase.co')) {
          onMessage?.call('썸네일 이미지 URL 형식이 올바르지 않습니다.');
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
        onMessage?.call('변경 사항이 없습니다.');
        return;
      }

      // 최종 DB 업데이트
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
}
