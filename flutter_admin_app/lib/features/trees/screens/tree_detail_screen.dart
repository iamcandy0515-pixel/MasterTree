import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_detail_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/screens/widgets/detail_parts/tree_basic_info_section.dart';
import 'package:flutter_admin_app/features/trees/screens/widgets/detail_parts/tree_hint_section.dart';
import 'package:flutter_admin_app/features/trees/screens/widgets/detail_parts/tree_preview_dialog.dart';

class TreeDetailScreen extends StatelessWidget {
  final Tree tree;

  const TreeDetailScreen({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeDetailViewModel(tree: tree),
      child: const _TreeDetailContent(),
    );
  }
}

class _TreeDetailContent extends StatelessWidget {
  const _TreeDetailContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeDetailViewModel>();
    final tree = vm.tree;

    return Scaffold(
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _TreeTitle(tree: tree),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: TreeBasicInfoSection()),
                _PreviewButton(vm: vm),
              ],
            ),
            const SizedBox(height: 32),
            const TreeHintSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TreeTitle extends StatelessWidget {
  final Tree tree;
  const _TreeTitle({required this.tree});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: tree.nameKr,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (tree.scientificName?.isNotEmpty == true)
            TextSpan(
              text: ' (${tree.scientificName})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final TreeDetailViewModel vm;
  const _PreviewButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => TreePreviewDialog.show(
        context,
        barkImages: vm.tree.images.where((img) => img.imageType == 'bark').toList(),
        leafImages: vm.tree.images.where((img) => img.imageType == 'leaf').toList(),
        barkHint: vm.hintControllers['bark']?.text ?? '',
        leafHint: vm.hintControllers['leaf']?.text ?? '',
      ),
      icon: const Icon(Icons.remove_red_eye, size: 16, color: NeoColors.acidLime),
      label: const Text(
        '미리보기',
        style: TextStyle(color: NeoColors.acidLime, fontWeight: FontWeight.bold),
      ),
    );
  }
}
