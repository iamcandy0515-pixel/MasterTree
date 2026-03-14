import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/tree_list_controller.dart';
import 'tree_list/widgets/tree_list_header.dart';
import 'tree_list/widgets/tree_list_pagination.dart';
import 'tree_list/widgets/tree_detail_sheet.dart';

class TreeListScreen extends StatefulWidget {
  const TreeListScreen({super.key});

  @override
  State<TreeListScreen> createState() => _TreeListScreenState();
}

class _TreeListScreenState extends State<TreeListScreen> {
  final TreeListController _controller = TreeListController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _controller.loadSavedFilters();
    _searchController.text = _controller.searchQuery;
    _controller.fetchTrees(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          TreeListHeader(
            controller: _controller,
            searchController: _searchController,
            onUpdate: () => setState(() {}),
          ),
          Expanded(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _controller.filteredTrees.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              TreeListPagination(
                                controller: _controller,
                                onUpdate: () => setState(() {}),
                              ),
                              const SizedBox(height: 8),
                              _buildTreeList(context),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.forest_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        const Text('등록된 수목이 없습니다.', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
      ],
    );
  }

  Widget _buildTreeList(BuildContext context) {
    final startIndex = _controller.currentPage * TreeListController.itemsPerPage;
    final pagedTrees = _controller.filteredTrees.skip(startIndex).take(TreeListController.itemsPerPage).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pagedTrees.length,
      separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
      itemBuilder: (context, index) {
        final tree = pagedTrees[index];
        return InkWell(
          onTap: () => _showTreeDetail(context, tree),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tree['name_kr'] ?? '이름 없음',
                            style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(tree['category'] ?? '-'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showTreeDetail(BuildContext context, Map<String, dynamic> tree) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TreeDetailSheet(tree: tree),
    );
  }
}
