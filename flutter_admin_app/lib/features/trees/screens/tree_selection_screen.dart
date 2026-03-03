import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_detail_screen.dart';

class TreeSelectionScreen extends StatelessWidget {
  const TreeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeSelectionViewModel(),
      child: const _TreeSelectionContent(),
    );
  }
}

class _TreeSelectionContent extends StatefulWidget {
  const _TreeSelectionContent();

  @override
  State<_TreeSelectionContent> createState() => _TreeSelectionContentState();
}

class _TreeSelectionContentState extends State<_TreeSelectionContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeSelectionViewModel>();

    return Scaffold(
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('수목 추가'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '수목 검색',
                  style: TextStyle(
                    color: NeoColors.acidLime,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: vm.search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '수목 이름 또는 학명 검색',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF1E2518),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip(vm, '침엽수'),
                    const SizedBox(width: 8),
                    _buildFilterChip(vm, '활엽수'),
                    const SizedBox(width: 16),
                    // Pagination Controls
                    if (vm.totalPages > 1)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: vm.currentPage > 1 ? vm.prevPage : null,
                            icon: const Icon(Icons.chevron_left, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.white,
                            disabledColor: Colors.grey[800],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${vm.currentPage}/${vm.totalPages}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: vm.currentPage < vm.totalPages
                                ? vm.nextPage
                                : null,
                            icon: const Icon(Icons.chevron_right, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.white,
                            disabledColor: Colors.grey[800],
                          ),
                        ],
                      ),
                    const Spacer(),
                    if (vm.selectedTrees.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${vm.selectedTrees.length}건',
                          style: const TextStyle(
                            color: NeoColors.acidLime,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: vm.selectedTrees.isEmpty
                          ? null
                          : () {
                              Navigator.pop(context, vm.selectedTrees);
                            },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '추가',
                        style: TextStyle(
                          color: vm.selectedTrees.isNotEmpty
                              ? NeoColors.acidLime
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Selected Trees Chips
          if (vm.selectedTrees.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white.withOpacity(0.02),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vm.selectedTrees.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tree = vm.selectedTrees[index];
                  return Chip(
                    label: Text(tree.nameKr),
                    backgroundColor: NeoColors.acidLime,
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.black,
                    ),
                    onDeleted: () => vm.clearSelection(tree),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

          // Tree List
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: vm.paginatedTrees.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemBuilder: (context, index) {
                      final tree = vm.paginatedTrees[index];
                      final isSelected = vm.isSelected(tree);
                      return _buildTreeItem(tree, isSelected, vm);
                    },
                  ),
          ),

          // Bottom Action
          // Bottom Action removed as requested
        ],
      ),
    );
  }

  Widget _buildTreeItem(Tree tree, bool isSelected, TreeSelectionViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4), // Reduced spacing
      decoration: BoxDecoration(
        color: Colors.transparent, // Removed background
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(
                color: NeoColors.acidLime,
                width: 2,
              ) // Keep selection border?
            : null, // Removed default border
      ),
      child: ListTile(
        onTap: () => vm.toggleSelection(tree),
        contentPadding: const EdgeInsets.all(8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[800],
            image: tree.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(tree.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        title: Text(
          tree.nameKr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tree.scientificName ?? '',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TreeDetailScreen(tree: tree),
                  ),
                );
                // Assuming TreeLookalikeDetailScreen is generic or we pass tree data
                // For now, since LookalikeDetail is specific, let's just show a snackbar or TODO
                // But user asked for "page navigate".
                // Let's assume we can navigate to a detail screen.
                // Ideally we'd have a TreeDetailScreen.
              },
              icon: Icon(Icons.chevron_right, color: Colors.grey[400]),
            ),
            const SizedBox(width: 4),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? NeoColors.acidLime.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? NeoColors.acidLime : Colors.grey[600]!,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 20, color: NeoColors.acidLime)
                  : const Icon(Icons.add, size: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(TreeSelectionViewModel vm, String label) {
    final isSelected = vm.selectedCategory == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        vm.setCategory(selected ? label : null);
      },
      backgroundColor: const Color(0xFF1E2518),
      selectedColor: NeoColors.acidLime.withOpacity(0.2),
      checkmarkColor: NeoColors.acidLime,
      labelStyle: TextStyle(
        color: isSelected ? NeoColors.acidLime : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? NeoColors.acidLime : Colors.grey[800]!,
        ),
      ),
    );
  }
}
