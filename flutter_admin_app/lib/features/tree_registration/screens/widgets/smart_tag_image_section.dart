import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/tree_registration/viewmodels/tree_registration_viewmodel.dart';
import 'tree_registration_parts/tag_selector_row.dart';
import 'tree_registration_parts/tag_image_display.dart';
import 'tree_registration_parts/tag_upload_actions.dart';
import 'tree_registration_parts/tag_hint_input.dart';

class SmartTagImageSection extends StatelessWidget {
  const SmartTagImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeRegistrationViewModel>();

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
            '2. 부위별 이미지 및 힌트',
            style: TextStyle(
              color: Color(0xFF80F20D),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Tag Selection (Chips)
          TagSelectorRow(
            activeTag: vm.activeTag,
            tags: tags,
            taggedImages: vm.taggedImages,
            onTagSelected: (tag) => vm.setActiveTag(tag),
          ),
          const SizedBox(height: 20),

          // Image & Hint Area for Active Tag
          _buildActiveTagEditor(context, vm),
        ],
      ),
    );
  }

  Widget _buildActiveTagEditor(
    BuildContext context,
    TreeRegistrationViewModel vm,
  ) {
    final image = vm.taggedImages[vm.activeTag];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Image Area
          if (image == null)
            TagUploadActions(
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
            )
          else
            TagImageDisplay(
              imageUrl: image.imageUrl,
              onDelete: () => vm.removeImage(vm.activeTag),
            ),

          const SizedBox(height: 20),

          // Hint Area
          TagHintInput(
            initialHint: image?.hint,
            onChanged: (v) => vm.updateHint(vm.activeTag, v),
          ),
        ],
      ),
    );
  }
}
