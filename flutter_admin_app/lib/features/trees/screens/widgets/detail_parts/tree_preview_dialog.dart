import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/core/api/node_api.dart';

class TreePreviewDialog extends StatefulWidget {
  final Tree tree;
  final Map<String, String> hints;

  const TreePreviewDialog({
    super.key,
    required this.tree,
    required this.hints,
  });

  static void show(
    BuildContext context, {
    required Tree tree,
    required Map<String, String> hints,
  }) {
    showDialog(
      context: context,
      builder: (context) => TreePreviewDialog(
        tree: tree,
        hints: hints,
      ),
    );
  }

  @override
  State<TreePreviewDialog> createState() => _TreePreviewDialogState();
}

class _TreePreviewDialogState extends State<TreePreviewDialog> {
  String _selectedCategory = 'main';
  final List<Map<String, String>> _categories = [
    {'id': 'main', 'label': '대표'},
    {'id': 'leaf', 'label': '잎'},
    {'id': 'bark', 'label': '수피'},
    {'id': 'flower', 'label': '꽃'},
    {'id': 'fruit', 'label': '열매'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141811),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSmartTags(),
            const SizedBox(height: 20),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '스마트 미리보기',
              style: TextStyle(color: NeoColors.acidLime, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.tree.nameKr,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSmartTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat['label']!),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat['id']!),
              selectedColor: NeoColors.acidLime,
              backgroundColor: Colors.white.withOpacity(0.05),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    final images = widget.tree.images.where((img) => img.imageType == _selectedCategory).toList();
    final hint = widget.hints[_selectedCategory] ?? '';

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildImageSection(images.isNotEmpty ? images.first : null),
        ),
        if (hint.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildHintSection(hint),
        ],
      ],
    );
  }

  Widget _buildImageSection(TreeImage? image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: image?.imageUrl.isNotEmpty == true
          ? CachedNetworkImage(
              imageUrl: NodeApi.getProxyImageUrl(image!.imageUrl, width: 600),
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: NeoColors.acidLime)),
              errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24, size: 40),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 48),
                  SizedBox(height: 12),
                  Text('해당 카테고리의 이미지가 없습니다.', style: TextStyle(color: Colors.white24, fontSize: 13)),
                ],
              ),
            ),
    );
  }

  Widget _buildHintSection(String hint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoColors.acidLime.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.acidLime.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: NeoColors.acidLime, size: 16),
              SizedBox(width: 8),
              Text('부위별 힌트 (AI)', style: TextStyle(color: NeoColors.acidLime, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(hint, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
