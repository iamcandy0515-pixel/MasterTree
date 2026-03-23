import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageUploadZone extends StatelessWidget {
  final Future<void> Function() onPickImage;
  final Future<void> Function() onPaste;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isEmpty;
  
  static const primaryColor = Color(0xFF2BEE8C);

  const ImageUploadZone({
    super.key,
    required this.onPickImage,
    required this.onPaste,
    required this.focusNode,
    required this.isFocused,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
        onPickImage();
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): onPaste,
        },
        child: Focus(
          focusNode: focusNode,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused ? primaryColor : Colors.white10,
                width: isFocused ? 2 : 1,
              ),
            ),
            child: isEmpty
                ? Container(
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
                          color: isFocused ? primaryColor : Colors.white24,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '이미지 추가 또는 Ctrl+V',
                          style: TextStyle(
                            color: isFocused ? primaryColor : Colors.white24,
                            fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
