import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_modal_viewmodel.dart';

class TreeSelectionRow extends StatelessWidget {
  final Tree tree;
  final TreeSelectionModalViewModel vm;

  const TreeSelectionRow({
    super.key,
    required this.tree,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.isSelected(tree);
    final isAlreadyMember = vm.isAlreadyMember(tree);

    return ListTile(
      visualDensity: VisualDensity.compact,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    tree.nameKr,
                    style: GoogleFonts.notoSans(
                      color: isSelected ? NeoColors.acidLime : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (tree.category != null && tree.category!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '[${tree.category}]',
                    style: TextStyle(
                      color: isSelected ? NeoColors.acidLime : Colors.white24,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (tree.scientificName != null)
            Text(
              tree.scientificName!,
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: isAlreadyMember
          ? Icon(Icons.check_circle, color: Colors.grey[800], size: 18)
          : Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? NeoColors.acidLime : Colors.white10,
              size: 18,
            ),
      onTap: isAlreadyMember ? null : () => vm.toggleSelection(tree),
    );
  }
}
