import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/tree.dart';
import '../../repositories/tree_repository.dart';
import '../../viewmodels/tree_sourcing_viewmodel.dart';
import '../../../../core/theme/neo_theme.dart';

class SourcingImageSlot extends StatelessWidget {
  final TreeSourcingViewModel vm;
  final String type;
  final String label;
  final bool isThumb;

  const SourcingImageSlot({
    super.key,
    required this.vm,
    required this.type,
    required this.label,
    required this.isThumb,
  });

  @override
  Widget build(BuildContext context) {
    final key = '${type}_${isThumb ? 'thumb' : 'original'}';
    final existing = vm.getImageByType(type);


    // Resolve display content
    final stagedData = vm.pendingImages[key];
    final displayItem = stagedData ?? 
        (isThumb ? (existing?.thumbnailUrl?.isNotEmpty == true ? existing : null) 
                 : (existing?.imageUrl.isNotEmpty == true ? existing : null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            _buildActions(context),
          ],
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.4,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                clipBehavior: Clip.antiAlias,
                child: displayItem != null
                    ? _buildImageDisplay(displayItem)
                    : const Center(child: Icon(Icons.add_a_photo_outlined, color: Colors.white10, size: 32)),
              ),
              if (displayItem != null)
                Positioned(top: 8, right: 8, child: _buildSourceBadge(key, displayItem)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final key = '${type}_${isThumb ? 'thumb' : 'original'}';
    final isStaged = vm.pendingImages.containsKey(key);

    return Row(
      children: [
        IconButton(
          onPressed: () => vm.pickImage(type, isThumbnail: isThumb),
          icon: const Icon(Icons.photo_library, size: 16, color: Colors.white38),
          tooltip: '갤러리',
          constraints: const BoxConstraints(minWidth: 32),
        ),
        IconButton(
          onPressed: () => _showUrlInputDialog(context),
          icon: const Icon(Icons.link, size: 16, color: Colors.white38),
          tooltip: 'URL 설정',
          constraints: const BoxConstraints(minWidth: 32),
        ),
        if (isStaged)
          IconButton(
            onPressed: () => vm.removePendingImage(key),
            icon: const Icon(Icons.undo, size: 16, color: Colors.orange),
            tooltip: '변경취소',
            constraints: const BoxConstraints(minWidth: 32),
          ),
      ],
    );
  }

  Widget _buildSourceBadge(String key, dynamic displayItem) {
    final source = vm.imageSources[key] ?? 'db';
    String text = 'DB 정보';
    Color color = Colors.blue.withValues(alpha: 0.8);

    if (source == 'google') {
      text = '구글 정보';
      color = NeoColors.acidLime.withValues(alpha: 0.9);
    } else if (source == 'manual') {
      text = '수정 중';
      color = Colors.orange.withValues(alpha: 0.8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(
        text,
        style: TextStyle(
          color: color == NeoColors.acidLime.withValues(alpha: 0.9) ? Colors.black : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImageDisplay(dynamic displayItem) {
    if (displayItem is XFile) {
      return Image.network(displayItem.path, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image));
    } else if (displayItem is Uint8List) {
      return Image.memory(displayItem, fit: BoxFit.cover);
    } else if (displayItem is TreeImage) {
      final url = isThumb ? displayItem.thumbnailUrl : displayItem.imageUrl;
      if (url == null || url.isEmpty) return const Center(child: Icon(Icons.image_not_supported));

      return CachedNetworkImage(
        imageUrl: TreeRepository.getProxyUrl(url),
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.redAccent, size: 24),
        memCacheWidth: 600,
      );
    }
    return const SizedBox();
  }

  Future<void> _showUrlInputDialog(BuildContext context) async {
    final controller = TextEditingController();
    final key = '${type}_${isThumb ? 'thumb' : 'original'}';
    final current = vm.pendingImages[key] ?? vm.getImageByType(type);

    if (current is TreeImage) {
      controller.text = (isThumb ? current.thumbnailUrl : current.imageUrl) ?? '';
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('적용')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final image = TreeImage(imageType: type, imageUrl: isThumb ? '' : result, thumbnailUrl: isThumb ? result : null);
      vm.stageImage(type, image, isThumbnail: isThumb, source: 'manual');
    }
  }
}
