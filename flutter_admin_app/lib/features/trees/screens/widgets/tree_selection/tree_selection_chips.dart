import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_modal_viewmodel.dart';

class TreeSelectionChips extends StatelessWidget {
  final TreeSelectionModalViewModel vm;

  const TreeSelectionChips({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.selectedTrees.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: vm.selectedTrees.map((tree) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(
                  tree.nameKr,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: NeoColors.acidLime,
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => vm.toggleSelection(tree),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
