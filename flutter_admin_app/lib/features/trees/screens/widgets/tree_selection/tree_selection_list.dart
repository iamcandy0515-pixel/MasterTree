import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_modal_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/screens/widgets/tree_selection/tree_selection_row.dart';

class TreeSelectionList extends StatelessWidget {
  final TreeSelectionModalViewModel vm;

  const TreeSelectionList({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.trees.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: NeoColors.acidLime),
        ),
      );
    }

    if (vm.trees.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('수목이 없습니다.', style: TextStyle(color: Colors.grey[500])),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: vm.trees.length,
      itemBuilder: (context, index) {
        return TreeSelectionRow(
          tree: vm.trees[index],
          vm: vm,
        );
      },
    );
  }
}
