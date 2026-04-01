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
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              _buildImageStack(item['count'] ?? 0),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['group_name'] ??
                                '${item['tree1']} vs ${item['tree2']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          ' (${item['count']}건)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.info,
                            color: AppColors.primary, size: 14),
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

  Widget _buildImageStack(int count) {
    return SizedBox(
      width: 72,
      height: 40,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _buildIconAvatar(Icons.park_rounded, 0),
          ),
          if (count > 1)
            Positioned(
              left: 24,
              child: _buildIconAvatar(Icons.nature_rounded, 1),
            ),
          if (count > 2)
            Positioned(
              left: 48,
              child: _buildIconAvatar(Icons.more_horiz, 2, isEllipsis: true),
            ),
        ],
      ),
    );
  }

  Widget _buildIconAvatar(IconData icon, int index, {bool isEllipsis = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.backgroundDark,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: AppColors.primary,
          size: isEllipsis ? 16 : 20,
        ),
      ),
    );
  }
}

