import 'package:flutter/material.dart';
import '../../viewmodels/tree_sourcing_viewmodel.dart';
import '../../../../core/theme/neo_theme.dart';
import 'sourcing_image_slot.dart';

class SourcingCategorySection extends StatelessWidget {
  final TreeSourcingViewModel vm;
  final String type;
  final String label;

  const SourcingCategorySection({
    super.key,
    required this.vm,
    required this.type,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final existing = vm.getImageByType(type);
    final isOriginalMissing = vm.fileMissing['${type}_original'] ?? false;
    final isThumbMissing = vm.fileMissing['${type}_thumb'] ?? false;

    final hasOriginal =
        vm.pendingImages.containsKey('${type}_original') ||
        (existing?.imageUrl.isNotEmpty == true && !isOriginalMissing);

    // 썸네일 버튼 노출 조건 (hasThumb이 false면 버튼 활성화됨)
    // 1. db정보는 있으나 구글에 파일이 없는 경우 (isThumbMissing = true -> hasThumb = false)
    // 2. db나 pending에 url이 아예 없는경우 (false)
    final hasThumb =
        vm.pendingImages.containsKey('${type}_thumb') ||
        (existing?.thumbnailUrl?.isNotEmpty == true && !isThumbMissing);

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeoColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasOriginal && !hasThumb)
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
                child: SourcingImageSlot(
                  vm: vm,
                  type: type,
                  label: '원본',
                  isThumb: false,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SourcingImageSlot(
                  vm: vm,
                  type: type,
                  label: '썸네일',
                  isThumb: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
