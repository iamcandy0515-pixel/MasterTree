import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';

class TreePreviewDialog extends StatelessWidget {
  final List<TreeImage> barkImages;
  final List<TreeImage> leafImages;
  final String barkHint;
  final String leafHint;

  const TreePreviewDialog({
    super.key,
    required this.barkImages,
    required this.leafImages,
    required this.barkHint,
    required this.leafHint,
  });

  static void show(
    BuildContext context, {
    required List<TreeImage> barkImages,
    required List<TreeImage> leafImages,
    required String barkHint,
    required String leafHint,
  }) {
    showDialog(
      context: context,
      builder: (context) => TreePreviewDialog(
        barkImages: barkImages,
        leafImages: leafImages,
        barkHint: barkHint,
        leafHint: leafHint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E2518),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '미리보기 (수피/잎)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '수피',
                        style: TextStyle(
                          color: NeoColors.acidLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 1,
                        child: barkImages.isNotEmpty
                            ? _buildImageCard(barkImages.first, barkHint)
                            : _buildNoImagePlaceholder(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '잎',
                        style: TextStyle(
                          color: NeoColors.acidLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 1,
                        child: leafImages.isNotEmpty
                            ? _buildImageCard(leafImages.first, leafHint)
                            : _buildNoImagePlaceholder(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(TreeImage image, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
          if (hint.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                padding: const EdgeInsets.all(8),
                child: Text(
                  hint,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        '등록된 이미지가 없습니다.',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
    );
  }
}
