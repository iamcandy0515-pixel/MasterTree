import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../core/api_service.dart';
import '../../../core/widgets/fullscreen_image_viewer.dart';

class VisualComparisonSection extends StatelessWidget {
  final String tree1Name;
  final String tree2Name;
  final String? url1;
  final String? url2;

  const VisualComparisonSection({
    super.key,
    required this.tree1Name,
    required this.tree2Name,
    this.url1,
    this.url2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildImageHalf(
              context,
              tree1Name,
              url1 ?? 'https://via.placeholder.com/400?text=$tree1Name',
              isLeft: true,
            ),
          ),
          const VerticalDivider(width: 2, color: Colors.white12),
          Expanded(
            child: _buildImageHalf(
              context,
              tree2Name,
              url2 ?? 'https://via.placeholder.com/400?text=$tree2Name',
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHalf(BuildContext context, String name, String imageUrl, {required bool isLeft}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullscreenImageViewer(imageUrl: imageUrl, title: name),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              ApiService.getProxyImageUrl(imageUrl),
              fit: BoxFit.cover,
              cacheWidth: 500,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.white.withOpacity(0.05),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white.withOpacity(0.05),
                  child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40)),
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: isLeft ? 16 : null,
            right: !isLeft ? 16 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: isLeft ? 12 : null,
            left: !isLeft ? 12 : null,
            child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

