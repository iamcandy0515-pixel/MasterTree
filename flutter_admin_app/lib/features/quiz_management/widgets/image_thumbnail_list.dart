import 'package:flutter/material.dart';
import './image_thumbnail_tile.dart';

class ImageThumbnailList extends StatelessWidget {
  final List<dynamic> blocks;
  final String field; // 'question' or 'explanation'
  final Function(int) onRemove;

  const ImageThumbnailList({
    super.key,
    required this.blocks,
    required this.field,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    final imageBlocks = blocks.where((dynamic b) => b['type'] == 'image').toList();
    if (imageBlocks.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageBlocks.length,
        itemBuilder: (context, index) {
          final dynamic block = imageBlocks[index];
          final realIndex = blocks.indexOf(block);
          final title = field == 'question' ? '문제 이미지' : '정답 및 해설 이미지';

          return ImageThumbnailTile(
            imageUrl: (block['content'] as String),
            title: title,
            onDelete: () => onRemove(realIndex),
          );
        },
      ),
    );
  }
}
