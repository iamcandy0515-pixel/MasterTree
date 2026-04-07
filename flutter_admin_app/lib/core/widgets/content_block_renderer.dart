import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_admin_app/core/widgets/fullscreen_image_viewer.dart';

class ContentBlockRenderer extends StatelessWidget {
  final List<dynamic> blocks;
  final TextStyle? textStyle;
  final double spacing;
  final bool hideImages;

  const ContentBlockRenderer({
    super.key,
    required this.blocks,
    this.textStyle,
    this.spacing = 8.0,
    this.hideImages = false,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((dynamic block) {
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
                Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
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
                        color: Color(0xFF2BEE8C),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, dynamic error) => Container(
                    height: 100,
                    color: Colors.white10,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing / 2),
      child: Text(
        content,
        style:
            textStyle ??
            GoogleFonts.inter(color: Colors.white, fontSize: 15, height: 1.5),
      ),
    );
  }
}
