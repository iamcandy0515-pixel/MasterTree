import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/tree_registration/viewmodels/tree_registration_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
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
            '2. 부위별 이미지 및 힌트',
            style: TextStyle(
              color: Color(0xFF80F20D),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Tag Selection Row (Rebuilds when activeTag or taggedImages changes labels)
          Selector<TreeRegistrationViewModel, String>(
            selector: (_, vm) => vm.activeTag,
            builder: (context, activeTag, _) {
              return TagSelectorRow(
                activeTag: activeTag,
                tags: tags,
                taggedImages: context.read<TreeRegistrationViewModel>().taggedImages,
                onTagSelected: (tag) => vm.setActiveTag(tag),
              );
            },
          ),
          const SizedBox(height: 20),

          // Active Tag Editor (Rebuilds ONLY when activeTag, image data, or uploading state changes)
          Selector<TreeRegistrationViewModel, _ActiveEditorState>(
            selector: (_, vm) => _ActiveEditorState(
              vm.activeTag,
              vm.taggedImages[vm.activeTag],
              vm.isUploading,
            ),
            builder: (context, state, _) {
              return ActiveTagEditor(
                activeTag: state.activeTag,
                image: state.image,
                isUploading: state.isUploading,
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

class _ActiveEditorState {
  final String activeTag;
  final TreeImage? image;
  final bool isUploading;

  _ActiveEditorState(this.activeTag, this.image, this.isUploading);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ActiveEditorState &&
          runtimeType == other.runtimeType &&
          activeTag == other.activeTag &&
          image?.imageUrl == other.image?.imageUrl &&
          image?.hint == other.image?.hint &&
          isUploading == other.isUploading;

  @override
  int get hashCode =>
      activeTag.hashCode ^
      (image?.imageUrl.hashCode ?? 0) ^
      (image?.hint.hashCode ?? 0) ^
      isUploading.hashCode;
}
