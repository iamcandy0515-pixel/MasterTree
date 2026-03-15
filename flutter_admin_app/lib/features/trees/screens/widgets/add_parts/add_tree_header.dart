import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class AddTreeHeader extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<FormState> formKey;

  const AddTreeHeader({
    super.key,
    required this.scaffoldKey,
    required this.formKey,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddTreeViewModel>();
    final isEditMode = vm.originalTree != null;

    return AppBar(
      title: Text(
        isEditMode ? '나무 정보 수정' : '새 나무 등록',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      actions: [
        _PreviewButton(scaffoldKey: scaffoldKey),
        if (isEditMode) _DeleteButton(vm: vm),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _PreviewButton({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
      icon: const Icon(Icons.smartphone, size: 14, color: NeoColors.acidLime),
      label: const Text(
        '미리보기',
        style: TextStyle(
          color: NeoColors.acidLime,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final AddTreeViewModel vm;
  const _DeleteButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.redAccent),
      onPressed: () => _confirmDelete(context, vm),
      tooltip: '이 나무 삭제',
    );
  }

  void _confirmDelete(BuildContext context, AddTreeViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('나무 삭제', style: TextStyle(color: Colors.white)),
        content: const Text(
          '정말로 이 나무 데이터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await vm.deleteTree();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('나무가 삭제되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
