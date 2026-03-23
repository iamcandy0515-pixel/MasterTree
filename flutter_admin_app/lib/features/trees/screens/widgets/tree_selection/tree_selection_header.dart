import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_modal_viewmodel.dart';

class TreeSelectionHeader extends StatelessWidget {
  final TreeSelectionModalViewModel vm;

  const TreeSelectionHeader({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '비교수목 추가${vm.selectedTrees.isNotEmpty ? ' (${vm.selectedTrees.length})' : ''}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: vm.selectedTrees.isEmpty
                ? null
                : () {
                    Navigator.pop(context, vm.selectedTrees);
                  },
            style: TextButton.styleFrom(
              backgroundColor: NeoColors.acidLime.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              '추가',
              style: TextStyle(
                color: NeoColors.acidLime,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
