import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_modal_viewmodel.dart';

class TreePaginationBar extends StatelessWidget {
  final TreeSelectionModalViewModel vm;

  const TreePaginationBar({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: vm.currentPage > 1 ? vm.prevPage : null,
            icon: const Icon(Icons.chevron_left, size: 24),
            color: Colors.white70,
            disabledColor: Colors.white10,
          ),
          Text(
            '${vm.currentPage} / ${vm.totalPages}',
            style: const TextStyle(
              color: NeoColors.acidLime,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          IconButton(
            onPressed: vm.currentPage < vm.totalPages ? vm.nextPage : null,
            icon: const Icon(Icons.chevron_right, size: 24),
            color: Colors.white70,
            disabledColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}
