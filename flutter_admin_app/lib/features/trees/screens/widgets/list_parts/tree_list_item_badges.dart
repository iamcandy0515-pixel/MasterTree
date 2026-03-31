import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';

class TreeListItemBadges extends StatelessWidget {
  final Tree tree;
  final Color primary;

  const TreeListItemBadges({super.key, required this.tree, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallTag(label: tree.category ?? '전체', color: primary),
        const SizedBox(width: 8),
        _PublishedBadge(color: primary),
        if (!tree.isAutoQuizEnabled) ...[
          const SizedBox(width: 8),
          const _ComparisonOnlyBadge(),
        ],
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('게시됨', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _ComparisonOnlyBadge extends StatelessWidget {
  const _ComparisonOnlyBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: const Text('비교 전용', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
