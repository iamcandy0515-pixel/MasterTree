import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/widgets/content_block_renderer.dart';

class QuizContentCard extends StatelessWidget {
  final List<dynamic> contentBlocks;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const QuizContentCard({
    super.key,
    required this.contentBlocks,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImages = contentBlocks.any((dynamic b) {
      final Map<String, dynamic> block = Map<String, dynamic>.from(b as Map);
      return block['type'] == 'image';
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '문제',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasImages)
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.photo_library,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: onToggleExpand,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: isExpanded ? '이미지 접기' : '이미지 펼치기',
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: RepaintBoundary(
            child: ContentBlockRenderer(
              blocks: contentBlocks,
              hideImages: !isExpanded,
            ),
          ),
        ),
      ],
    );
  }
}
