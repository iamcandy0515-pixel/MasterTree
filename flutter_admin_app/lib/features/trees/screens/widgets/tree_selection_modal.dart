import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_modal_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_group_edit_viewmodel.dart';

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

class _ModalContent extends StatefulWidget {
  const _ModalContent();

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeSelectionModalViewModel>();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, vm),
          if (vm.selectedTrees.isNotEmpty) _buildSelectionChips(vm),
          const Divider(color: Colors.white10, height: 1),
          _buildCategoryFilters(vm),
          const Divider(color: Colors.white10, height: 1),
          // Fixed height to show approx 5-6 items comfortably (compact)
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 450),
              child: _buildTreeList(vm),
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildPagination(vm),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TreeSelectionModalViewModel vm) {
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
          // '추가' 버튼을 제목 옆 오른쪽에 배치 (Requirement 3)
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

  Widget _buildSelectionChips(TreeSelectionModalViewModel vm) {
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

  Widget _buildCategoryFilters(TreeSelectionModalViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildFilterChip(vm, '침엽수'),
          const SizedBox(width: 8),
          _buildFilterChip(vm, '활엽수'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(TreeSelectionModalViewModel vm, String label) {
    final isSelected = vm.selectedCategory == label;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selectedColor: NeoColors.acidLime,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? NeoColors.acidLime : Colors.white30,
        ),
      ),
      onSelected: (selected) {
        vm.setCategory(selected ? label : null);
      },
    );
  }

  Widget _buildTreeList(TreeSelectionModalViewModel vm) {
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
        final tree = vm.trees[index];
        final isSelected = vm.isSelected(tree);
        final isAlreadyMember = vm.isAlreadyMember(tree);

        // Simple text-only layout (Requirement 2)
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
      },
    );
  }

  Widget _buildPagination(TreeSelectionModalViewModel vm) {
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
