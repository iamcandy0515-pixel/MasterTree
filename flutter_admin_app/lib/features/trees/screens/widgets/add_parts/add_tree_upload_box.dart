import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class AddTreeUploadBox extends StatelessWidget {
  final FocusNode focusNode;
  final bool isDragging;
  final String dropZoneViewId;
  final bool isUploading;
  final VoidCallback onPaste;

  const AddTreeUploadBox({
    super.key,
    required this.focusNode,
    required this.isDragging,
    required this.dropZoneViewId,
    required this.isUploading,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            final keys = HardwareKeyboard.instance.logicalKeysPressed;
            final isCtrlPressed = keys.contains(LogicalKeyboardKey.controlLeft) || 
                                  keys.contains(LogicalKeyboardKey.controlRight);
            final isCmdPressed = keys.contains(LogicalKeyboardKey.metaLeft) || 
                                 keys.contains(LogicalKeyboardKey.metaRight);
            final isVPressed = event.logicalKey == LogicalKeyboardKey.keyV;
            if ((isCtrlPressed || isCmdPressed) && isVPressed) {
              onPaste();
            }
          }
        },
        child: Stack(
          children: [
            if (kIsWeb)
              SizedBox(
                height: 100,
                child: HtmlElementView(viewType: dropZoneViewId),
              ),
            IgnorePointer(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDragging || focusNode.hasFocus ? NeoColors.acidLime : Colors.white10,
                    width: isDragging || focusNode.hasFocus ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDragging || focusNode.hasFocus
                      ? NeoColors.acidLime.withOpacity(0.05)
                      : Colors.white.withOpacity(0.02),
                ),
                child: isUploading
                    ? const Center(child: CircularProgressIndicator(color: NeoColors.acidLime))
                    : Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: isDragging ? NeoColors.acidLime : Colors.white38,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isDragging ? '여기에 놓으세요' : '클릭/드래그/붙여넣기 업로드',
                              style: const TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

