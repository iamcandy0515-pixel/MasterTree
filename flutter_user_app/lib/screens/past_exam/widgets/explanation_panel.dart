import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/widgets/content_block_renderer.dart';

class ExplanationPanel extends StatelessWidget {
  final List<dynamic> explanationBlocks;
  final String hintText;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const ExplanationPanel({
    super.key,
    required this.explanationBlocks,
    required this.hintText,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = explanationBlocks.any((b) => b['type'] == 'image');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (explanationBlocks.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '해설',
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
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: ContentBlockRenderer(
              blocks: explanationBlocks,
              isHighlight: true,
              hideImages: !isExpanded,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (hintText.isNotEmpty) ...[
          const Text(
            '힌트',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              hintText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
