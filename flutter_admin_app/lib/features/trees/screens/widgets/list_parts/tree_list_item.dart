import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_list_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_detail_screen.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class TreeListItem extends StatelessWidget {
  final Tree tree;
  const TreeListItem({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    const primary = NeoColors.acidLime;
    return InkWell(
      onTap: () => _navigateToEdit(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _ItemContent(tree: tree, primary: primary)),
            _DeleteButton(tree: tree),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) async {
    final vm = context.read<TreeListViewModel>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TreeDetailScreen(tree: tree)),
    );
    if (result == true) vm.fetchTrees();
  }
}

class _ItemContent extends StatelessWidget {
  final Tree tree;
  final Color primary;
  const _ItemContent({required this.tree, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: _Title(name: tree.nameKr)),
            const SizedBox(width: 8),
            if (!tree.isAutoQuizEnabled) _ComparisonOnlyBadge(),
            const SizedBox(width: 8),
            ...tree.category?.split('/').map((c) => _SmallTag(label: c.trim(), color: primary)) ?? [],
            const SizedBox(width: 8),
            _PublishedBadge(color: primary),
          ],
        ),
        const SizedBox(height: 8),
        _BadgeRow(tree: tree),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String name;
  const _Title({required this.name});
  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ComparisonOnlyBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: const Text('비교전용', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String label;
  final Color color;
  const _SmallTag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class _PublishedBadge extends StatelessWidget {
  final Color color;
  const _PublishedBadge({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('게시됨', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final Tree tree;
  const _BadgeRow({required this.tree});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CountBadge(
          icon: Icons.image_outlined,
          count: tree.images.length,
          color: Colors.blueAccent.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        _CountBadge(
          icon: Icons.lightbulb_outline,
          count: tree.images.where((img) => img.hint != null && img.hint!.isNotEmpty).length,
          color: Colors.orangeAccent.withValues(alpha: 0.7),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  const _CountBadge({required this.icon, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(count.toString(), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
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
        content: Text('${tree.nameKr} 수목을(를) 정말 삭제하시겠습니까?'),
        backgroundColor: const Color(0xFF15281E),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        contentTextStyle: const TextStyle(color: Colors.white70),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TreeListViewModel>().deleteTree(tree.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제되었습니다.')));
      }
    }
  }
}
