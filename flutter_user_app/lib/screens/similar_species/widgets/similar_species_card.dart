import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../species_comparison_detail_screen.dart';

class SimilarSpeciesCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const SimilarSpeciesCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpeciesComparisonDetailScreen(
              tree1: item['tree1']!,
              tree2: item['tree2']!,
              groupId: item['id'].toString(),
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              _buildImageStack(item['img1']!, item['img2']!),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['group_name'] ?? '${item['tree1']} vs ${item['tree2']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.info, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['desc']!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageStack(String img1, String img2) {
    return SizedBox(
      width: 64,
      height: 40,
      child: Stack(
        children: [
          _buildCircleAvatar(0, img1),
          _buildCircleAvatar(1, img2),
        ],
      ),
    );
  }

  Widget _buildCircleAvatar(int index, String url) {
    return Positioned(
      left: index * 24.0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.backgroundDark, width: 2),
          image: url.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: url.isEmpty
            ? const Center(child: Icon(Icons.park, size: 24, color: Colors.white10))
            : null,
      ),
    );
  }
}
