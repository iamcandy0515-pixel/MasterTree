import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/quiz_management/viewmodels/bulk_extraction_viewmodel.dart';
import 'image_preview_item.dart';

class ImageHorizontalList extends StatelessWidget {
  final BulkExtractionViewModel viewModel;
  final int qNum;
  final String field;
  final List imageBlocks;
  final List allBlocks;
  final VoidCallback onStateChange;

  const ImageHorizontalList({
    super.key,
    required this.viewModel,
    required this.qNum,
    required this.field,
    required this.imageBlocks,
    required this.allBlocks,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBlocks.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageBlocks.length,
        itemBuilder: (context, index) {
          final block = imageBlocks[index];
          final realIndex = allBlocks.indexOf(block);
          
          return ImagePreviewItem(
            imageUrl: block['content'],
            title: '${field == 'question' ? '문제' : '해설'} 이미지',
            onRemove: () {
              viewModel.removeImage(qNum, field, realIndex);
              onStateChange();
            },
          );
        },
      ),
    );
  }
}
