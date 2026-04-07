import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_detail_screen.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_list_viewmodel.dart';
import 'tree_list_item_thumbnail.dart';
import 'tree_list_item_badges.dart';

class TreeListItem extends StatelessWidget {
  final Tree tree;
  const TreeListItem({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    const primary = NeoColors.acidLime;
    
    return InkWell(
      onTap: () => _navigateToDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TreeListItemThumbnail(tree: tree),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tree.nameKr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  TreeListItemBadges(tree: tree, primary: primary),
                ],
              ),
            ),
            _DeleteButton(tree: tree),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) async {
    final vm = context.read<TreeListViewModel>();
    final dynamic result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(builder: (_) => TreeDetailScreen(tree: tree)),
    );
    if (result == true) vm.fetchTrees();
  }
}

class _DeleteButton extends StatelessWidget {
  final Tree tree;
  const _DeleteButton({required this.tree});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
      onPressed: () => _showDeleteDialog(context),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수목 삭제'),
        content: Text('${tree.nameKr} 수목을 정말 삭제하시겠습니까?'),
        backgroundColor: const Color(0xFF15281E),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        contentTextStyle: const TextStyle(color: Colors.white70),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TreeListViewModel>().deleteTree(tree.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다.')),
        );
      }
    }
  }
}
