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
    // Determine category from existing member if available
    String? initialCat;
    if (parentVm.members.isNotEmpty) {
      // Find category... ideally we could fetch it, but let's leave it null
      // if not strictly available from member class.
      // User requested "침엽수, 활엽수 정도의 구분자를 활용하여 자동 선택"
      // TreeGroupMember only contains treeName and keyCharacteristics.
      // E.g., if member name contains "구상나무" it's 침엽수, but best is to rely on actual data.
      // We will leave initialCat to null until we can resolve it accurately, or just pass it if loaded.
    }

    return ChangeNotifierProvider(
      create: (_) => TreeSelectionModalViewModel(
        existingMembers: parentVm.members,
        initialCategory: initialCat,
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeSelectionModalViewModel>();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, vm),
          if (vm.selectedTrees.isNotEmpty) _buildSelectionChips(vm),
          _buildSearchBar(vm),
          const Divider(color: Colors.white10, height: 1),
          _buildCategoryFilters(vm),
          _buildPagination(vm),
          const Divider(color: Colors.white10, height: 1),
          Flexible(child: _buildTreeList(vm)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TreeSelectionModalViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '비교수목 리스트${vm.selectedTrees.isNotEmpty ? ' (${vm.selectedTrees.length})' : ''}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    vm.selectedTrees,
                  ); // 모달 화면은 닫고 추가한 수목명을 셋으로 넘겨줌
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '추가',
                  style: TextStyle(
                    color: NeoColors.acidLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: NeoColors.acidLime,
                deleteIcon: const Icon(Icons.close, size: 16),
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

  Widget _buildSearchBar(TreeSelectionModalViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          onChanged: vm.search,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: '수목명 또는 학명 검색...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
            filled: true,
            fillColor: const Color(0xFF1E2518),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(TreeSelectionModalViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selectedColor: NeoColors.acidLime,
      backgroundColor: Colors.transparent,
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

        return ListTile(
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          title: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        tree.nameKr,
                        style: GoogleFonts.notoSansKr(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                        style: const TextStyle(
                          color: NeoColors.acidLime,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (tree.scientificName != null)
                Expanded(
                  flex: 2,
                  child: Text(
                    tree.scientificName!,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          trailing: isAlreadyMember
              ? Icon(Icons.check_circle, color: Colors.grey[600], size: 20)
              : isSelected
              ? const Icon(
                  Icons.check_circle,
                  color: NeoColors.acidLime,
                  size: 20,
                )
              : const Icon(
                  Icons.circle_outlined,
                  color: Colors.white30,
                  size: 20,
                ),
          onTap: isAlreadyMember ? null : () => vm.toggleSelection(tree),
          tileColor: Colors.transparent,
        );
      },
    );
  }

  Widget _buildPagination(TreeSelectionModalViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: vm.currentPage > 1 ? vm.firstPage : null,
            icon: const Icon(Icons.keyboard_double_arrow_left, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            color: Colors.white,
            disabledColor: Colors.grey[800],
          ),
          IconButton(
            onPressed: vm.currentPage > 1 ? vm.prevPage : null,
            icon: const Icon(Icons.chevron_left, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            color: Colors.white,
            disabledColor: Colors.grey[800],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2518),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${vm.currentPage} / ${vm.totalPages}',
              style: const TextStyle(
                color: NeoColors.acidLime,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: vm.currentPage < vm.totalPages ? vm.nextPage : null,
            icon: const Icon(Icons.chevron_right, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            color: Colors.white,
            disabledColor: Colors.grey[800],
          ),
          IconButton(
            onPressed: vm.currentPage < vm.totalPages ? vm.lastPage : null,
            icon: const Icon(Icons.keyboard_double_arrow_right, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            color: Colors.white,
            disabledColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }
}
