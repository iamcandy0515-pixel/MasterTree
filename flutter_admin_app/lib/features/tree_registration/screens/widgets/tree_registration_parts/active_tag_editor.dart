import 'package:flutter/material.dart';
import 'tag_upload_actions.dart';
import 'tag_image_display.dart';
import 'tag_hint_input.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';

class ActiveTagEditor extends StatelessWidget {
  final TreeImage? image;
  final bool isUploading;
  final String activeTag;
  final Function(dynamic) onPickImage;
  final Future<void> Function() onPasteImage;
  final Future<void> Function() onSearchGoogle;
  final Function(String) removeImage;
  final Function(String, String) updateHint;

  const ActiveTagEditor({
    super.key,
    required this.image,
    required this.isUploading,
    required this.activeTag,
    required this.onPickImage,
    required this.onPasteImage,
    required this.onSearchGoogle,
    required this.removeImage,
    required this.updateHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Area with RepaintBoundary for performance
          RepaintBoundary(
            child: image == null
                ? TagUploadActions(
                    isUploading: isUploading,
                    onPickImage: onPickImage,
                    onPasteImage: onPasteImage,
                    onSearchGoogle: onSearchGoogle,
                  )
                : TagImageDisplay(
                    imageUrl: image!.imageUrl,
                    onDelete: () => removeImage(activeTag),
                  ),
          ),
          const SizedBox(height: 20),
          // Hint Area
          TagHintInput(
            key: ValueKey('hint_${activeTag}_${image?.imageUrl}'),
            initialHint: image?.hint,
            onChanged: (v) => updateHint(activeTag, v),
          ),
        ],
      ),
    );
  }
}
