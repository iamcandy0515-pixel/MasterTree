import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/widgets/fullscreen_image_viewer.dart';

class ContentBlockRenderer extends StatelessWidget {
  final List<dynamic> blocks;
  final TextStyle? textStyle;
  final double spacing;
  final bool isHighlight;
  final bool hideImages;

  const ContentBlockRenderer({
    super.key,
    required this.blocks,
    this.textStyle,
    this.spacing = 8.0,
    this.isHighlight = false,
    this.hideImages = false,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        if (block is! Map) {
          final text = block?.toString() ?? '';
          if (text.trim().isEmpty) return const SizedBox.shrink();
          return _buildTextBlock(text);
        }

        final type = block['type'] as String?;
        final content = block['content']?.toString() ?? '';

        if (type == 'image') {
          if (hideImages) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.symmetric(vertical: spacing),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullscreenImageViewer(imageUrl: content),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: content,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.white10,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.white10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '이미지를 불러올 수 없습니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        } else {
          // Default to text
          return _buildTextBlock(content);
        }
      }).toList(),
    );
  }

  Widget _buildTextBlock(String content) {
    if (content.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing / 4),
      child: Text(
        content,
        style:
            textStyle ??
            GoogleFonts.inter(
              color: isHighlight
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.85),
              fontSize: 14,
              height: 1.5,
            ),
      ),
    );
  }
}

