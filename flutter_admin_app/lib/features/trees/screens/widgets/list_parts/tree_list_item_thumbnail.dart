import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';

class TreeListItemThumbnail extends StatelessWidget {
  final Tree tree;
  const TreeListItemThumbnail({super.key, required this.tree});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: NeoColors.acidLime.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.acidLime.withOpacity(0.1)),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(tree.category),
          color: NeoColors.acidLime.withOpacity(0.6),
          size: 30,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    if (category?.contains('침엽수') ?? false) return Icons.nature;
    if (category?.contains('활엽수') ?? false) return Icons.park;
    return Icons.eco;
  }
}
