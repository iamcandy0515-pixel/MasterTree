import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_modal_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_group_edit_viewmodel.dart';
import 'tree_selection/tree_selection_header.dart';
import 'tree_selection/tree_selection_chips.dart';
import 'tree_selection/tree_category_filters.dart';
import 'tree_selection/tree_selection_list.dart';
import 'tree_selection/tree_pagination_bar.dart';

class TreeSelectionModal extends StatelessWidget {
  final TreeGroupEditViewModel parentVm;

  const TreeSelectionModal({super.key, required this.parentVm});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeSelectionModalViewModel(
        existingMembers: parentVm.members,
        initialCategory: null,
      ),
      child: Dialog(
        backgroundColor: const Color(0xFF141A11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: const _ModalContent(),
      ),
    );
  }
}

class _ModalContent extends StatelessWidget {
  const _ModalContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeSelectionModalViewModel>();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TreeSelectionHeader(vm: vm),
          TreeSelectionChips(vm: vm),
          const Divider(color: Colors.white10, height: 1),
          TreeCategoryFilters(vm: vm),
          const Divider(color: Colors.white10, height: 1),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 450),
              child: TreeSelectionList(vm: vm),
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          TreePaginationBar(vm: vm),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
