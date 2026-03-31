import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/tree_registration/viewmodels/tree_registration_viewmodel.dart';
import 'tree_registration_parts/tag_selector_row.dart';
import 'tree_registration_parts/active_tag_editor.dart';

class SmartTagImageSection extends StatelessWidget {
  const SmartTagImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TreeRegistrationViewModel>();

    final tags = {
      'main': '대표',
      'leaf': '잎',
      'bark': '수피',
      'flower': '꽃',
      'fruit': '열매',
    };

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true):
            vm.pasteImageFromClipboard,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이미지 및 힌트',
            style: TextStyle(
              color: Color(0xFF80F20D),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'text 스마트 태그',
            style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Tag Selection Row (Rebuilds when activeTag or taggedImages changes labels)
          Consumer<TreeRegistrationViewModel>(
            builder: (context, vm, _) {
              return TagSelectorRow(
                activeTag: vm.activeTag,
                tags: tags,
                taggedImages: vm.taggedImages,
                onTagSelected: (tag) => vm.setActiveTag(tag),
              );
            },
          ),
          const SizedBox(height: 20),

          // Active Tag Editor (Rebuilds ONLY when activeTag, image data, or uploading state changes)
          Consumer<TreeRegistrationViewModel>(
            builder: (context, vm, _) {
              return ActiveTagEditor(
                activeTag: vm.activeTag,
                image: vm.taggedImages[vm.activeTag],
                isUploading: vm.isUploading,
                onPickImage: (file) => vm.handleImageUpload(file),
                onPasteImage: vm.pasteImageFromClipboard,
                onSearchGoogle: () async {
                  try {
                    await vm.searchGoogleImage();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                removeImage: vm.removeImage,
                updateHint: vm.updateHint,
              );
            },
          ),
        ],
      ),
    );
  }
}


