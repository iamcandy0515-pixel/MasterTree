import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_group_edit_viewmodel.dart';

class TreeGroupInfoSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;

  const TreeGroupInfoSection({
    super.key,
    required this.titleController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeGroupEditViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '그룹 정보',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (vm.isEditing)
              TextButton.icon(
                onPressed: () => _handleDelete(context, vm),
                icon: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.red[400],
                ),
                label: Text(
                  '그룹 삭제',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: titleController,
          onChanged: vm.setTitle,
          style: GoogleFonts.notoSansKr(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            labelText: '그룹 제목',
            hintText: '예: 봄꽃이 비슷한 나무',
            filled: true,
            fillColor: const Color(0xFF1E2518),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descController,
          onChanged: vm.setDescription,
          style: GoogleFonts.notoSansKr(color: Colors.white, fontSize: 14),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '비교 포인트 (팁)',
            hintText: '비슷한 수목들을 구분하는 핵심 팁을 입력하세요...',
            filled: true,
            fillColor: const Color(0xFF1E2518),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    TreeGroupEditViewModel vm,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('그룹 삭제'),
        content: const Text('이 유사 수목 그룹을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await vm.deleteGroup();
      if (success && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('그룹이 삭제되었습니다.')));
        Navigator.pop(context, true);
      }
    }
  }
}
