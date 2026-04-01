import 'package:flutter/material.dart';
import '../../../../core/design_system.dart';
import 'tree_attribute_row.dart';

class TreePartContent extends StatelessWidget {
  final String selectedTag;
  final String? hint;
  final Map<String, dynamic> tree;

  const TreePartContent({
    super.key,
    required this.selectedTag,
    required this.hint,
    required this.tree,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHint(),
        const SizedBox(height: 24),
        _buildDetailsList(),
      ],
    );
  }

  Widget _buildHint() {
    final bool isEmpty = hint == null || hint!.isEmpty || hint == '자료없음';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.white.withOpacity(0.03) : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          isEmpty ? '$selectedTag 파트가 없습니다.' : hint!,
          style: TextStyle(
            color: isEmpty ? AppColors.textMuted : AppColors.textLight,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TreeAttributeRow(
            icon: Icons.category,
            label: '구분',
            content: tree['category'] ?? '미분류',
          ),
          const SizedBox(height: 16),
          TreeAttributeRow(
            icon: Icons.filter_vintage,
            label: '수형',
            content: tree['shape'] ?? '정보 없음',
          ),
          const SizedBox(height: 16),
          TreeAttributeRow(
            icon: Icons.description,
            label: '상세 설명',
            content: tree['description'] ?? '설명 없음',
          ),
        ],
      ),
    );
  }
}
