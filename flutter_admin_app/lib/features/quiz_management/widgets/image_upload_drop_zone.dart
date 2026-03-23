import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';

class ImageUploadDropZone extends StatefulWidget {
  final bool isFocused;
  final bool isLoading;
  final VoidCallback onPickImage;
  final Function(Uint8List, String) onPasteImage;

  const ImageUploadDropZone({
    super.key,
    required this.isFocused,
    required this.isLoading,
    required this.onPickImage,
    required this.onPasteImage,
  });

  @override
  State<ImageUploadDropZone> createState() => _ImageUploadDropZoneState();
}

class _ImageUploadDropZoneState extends State<ImageUploadDropZone> {
  static const primaryColor = Color(0xFF2BEE8C);

  Future<void> _handlePaste() async {
    try {
      final bytes = await Pasteboard.image;
      if (bytes != null) {
        final fileName = 'pasted_image_${DateTime.now().millisecondsSinceEpoch}.png';
        widget.onPasteImage(bytes, fileName);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('클립보드에 이미지가 없습니다.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Paste error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPickImage,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): _handlePaste,
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isFocused ? primaryColor : Colors.white10,
              width: widget.isFocused ? 2 : 1,
            ),
          ),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: widget.isFocused ? primaryColor : Colors.white24,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  '이미지 추가 또는 Ctrl+V',
                  style: TextStyle(
                    color: widget.isFocused ? primaryColor : Colors.white24,
                    fontWeight: widget.isFocused ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
