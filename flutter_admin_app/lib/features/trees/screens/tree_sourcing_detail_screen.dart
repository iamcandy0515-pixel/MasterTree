import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/repositories/tree_repository.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_sourcing_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TreeSourcingDetailScreen extends StatelessWidget {
  final Tree tree;

  const TreeSourcingDetailScreen({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    // We use the provided ViewModel from the parent.
    final vm = Provider.of<TreeSourcingViewModel>(context);

    return Scaffold(
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('이미지 추출 및 상세 설정'),
        actions: [
          TextButton.icon(
            onPressed: vm.isLoading ? null : () => vm.fetchFromDrive(),
            icon: const Icon(Icons.cloud_download, color: NeoColors.acidLime),
            label: const Text(
              '드라이브 추출',
              style: TextStyle(color: NeoColors.acidLime),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton(
              onPressed: vm.isSaving || vm.pendingImages.isEmpty
                  ? null
                  : () async {
                      try {
                        await vm.saveChanges(
                          onMessage: (msg) {
                            if (context.mounted) {
                              final isWarning = msg.contains('확인하세요');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: isWarning
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              );
                              // 저장 성공(동일메시지가 아님)인 경우에만 화면 닫기
                              if (!isWarning) {
                                Navigator.pop(context, true);
                              }
                            }
                          },
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('저장 실패: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoColors.acidLime,
                foregroundColor: Colors.black,
              ),
              child: vm.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text('전체 저장'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  tree.nameKr,
                  style: const TextStyle(
                    color: NeoColors.acidLime,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildCategorySection(context, vm, 'main', '대표 이미지'),
              _buildCategorySection(context, vm, 'bark', '수피 (Bark)'),
              _buildCategorySection(context, vm, 'leaf', '잎 (Leaf)'),
              _buildCategorySection(context, vm, 'flower', '꽃 (Flower)'),
              _buildCategorySection(context, vm, 'fruit', '열매 / 겨울눈'),
            ],
          ),
          if (vm.isLoading)
            const Center(
              child: CircularProgressIndicator(color: NeoColors.acidLime),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    TreeSourcingViewModel vm,
    String type,
    String label,
  ) {
    // Get existing image from DB (cached in VM)
    final existing = vm.getImageByType(type);

    // Get staged images from VM
    final stagedOriginal = vm.pendingImages['${type}_original'];
    final stagedThumb = vm.pendingImages['${type}_thumb'];

    // Resolve what to show
    final originalToDisplay =
        stagedOriginal ??
        (existing?.imageUrl.isNotEmpty == true ? existing : null);
    final thumbToDisplay =
        stagedThumb ??
        (existing?.thumbnailUrl?.isNotEmpty == true ? existing : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeoColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (originalToDisplay != null && thumbToDisplay == null)
                TextButton.icon(
                  onPressed: () => vm.generateThumbnailForCategory(type),
                  icon: const Icon(
                    Icons.auto_fix_high,
                    size: 16,
                    color: NeoColors.acidLime,
                  ),
                  label: const Text(
                    '썸네일 생성 (WebP)',
                    style: TextStyle(color: NeoColors.acidLime, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildImageSlot(
                  context,
                  vm,
                  type,
                  '원본',
                  originalToDisplay,
                  false,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildImageSlot(
                  context,
                  vm,
                  type,
                  '썸네일',
                  thumbToDisplay,
                  true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlot(
    BuildContext context,
    TreeSourcingViewModel vm,
    String type,
    String label,
    dynamic displayItem,
    bool isThumb,
  ) {
    final key = '${type}_${isThumb ? 'thumb' : 'original'}';
    final isStaged = vm.pendingImages.containsKey(key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => vm.pickImage(type, isThumbnail: isThumb),
                  icon: const Icon(
                    Icons.photo_library,
                    size: 16,
                    color: Colors.white38,
                  ),
                  tooltip: '갤러리',
                  constraints: const BoxConstraints(minWidth: 32),
                ),
                IconButton(
                  onPressed: () =>
                      _showUrlInputDialog(context, vm, type, isThumb),
                  icon: const Icon(Icons.link, size: 16, color: Colors.white38),
                  tooltip: 'URL 설정',
                  constraints: const BoxConstraints(minWidth: 32),
                ),
                if (isStaged)
                  IconButton(
                    onPressed: () => vm.removePendingImage(key),
                    icon: const Icon(
                      Icons.undo,
                      size: 16,
                      color: Colors.orange,
                    ),
                    tooltip: '변경취소',
                    constraints: const BoxConstraints(minWidth: 32),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.4,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                clipBehavior: Clip.antiAlias,
                child: displayItem != null
                    ? _buildImageDisplay(displayItem, isThumb)
                    : const Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white10,
                          size: 32,
                        ),
                      ),
              ),
              if (displayItem != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildSourceBadge(isStaged, displayItem),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceBadge(bool isStaged, dynamic displayItem) {
    String text = '';
    Color color = Colors.black54;

    if (!isStaged) {
      text = 'DB 정보';
      color = Colors.blue.withValues(alpha: 0.8);
    } else {
      // Staged(Pending) 상태인 경우
      if (displayItem is Uint8List ||
          (displayItem is TreeImage &&
              (displayItem.imageUrl.contains('drive.google.com') ||
                  (displayItem.thumbnailUrl?.contains('drive.google.com') ??
                      false)))) {
        text = '구글 정보';
        color = NeoColors.acidLime.withValues(alpha: 0.9);
      } else {
        text = '수정 중';
        color = Colors.orange.withValues(alpha: 0.8);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == NeoColors.acidLime.withValues(alpha: 0.9)
              ? Colors.black
              : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImageDisplay(dynamic displayItem, bool isThumb) {
    if (displayItem is XFile) {
      return Image.network(
        displayItem.path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
      );
    } else if (displayItem is Uint8List) {
      return Image.memory(displayItem, fit: BoxFit.cover);
    } else if (displayItem is TreeImage) {
      final url = isThumb ? displayItem.thumbnailUrl : displayItem.imageUrl;
      if (url == null || url.isEmpty) {
        return const Center(child: Icon(Icons.image_not_supported));
      }

      return CachedNetworkImage(
        imageUrl: TreeRepository.getProxyUrl(url),
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.broken_image, color: Colors.redAccent, size: 24),
            SizedBox(height: 4),
            Text(
              '이미지 없음',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
        memCacheWidth: 600,
        maxWidthDiskCache: 1200,
      );
    }
    return const SizedBox();
  }

  Future<void> _showUrlInputDialog(
    BuildContext context,
    TreeSourcingViewModel vm,
    String type,
    bool isThumb,
  ) async {
    final controller = TextEditingController(text: '');
    final key = '${type}_${isThumb ? 'thumb' : 'original'}';
    final current = vm.pendingImages[key] ?? vm.getImageByType(type);

    if (current is TreeImage) {
      controller.text =
          (isThumb ? current.thumbnailUrl : current.imageUrl) ?? '';
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isThumb ? '썸네일' : '원본'} URL 설정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'http://...'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('적용'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final image = TreeImage(
        imageType: type,
        imageUrl: isThumb ? '' : result,
        thumbnailUrl: isThumb ? result : null,
      );
      vm.stageImage(type, image, isThumbnail: isThumb);
    }
  }
}
