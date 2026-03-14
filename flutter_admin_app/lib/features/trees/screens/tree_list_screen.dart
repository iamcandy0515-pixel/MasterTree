import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/core/utils/web_utils.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_list_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_detail_screen.dart';

class TreeListScreen extends StatelessWidget {
  const TreeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeListViewModel()..fetchTrees(),
      child: const _TreeListContent(),
    );
  }
}

class _TreeListContent extends StatefulWidget {
  const _TreeListContent();

  @override
  State<_TreeListContent> createState() => _TreeListScreenState();
}

class _TreeListScreenState extends State<_TreeListContent> {
  // stich Colors
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const textLight = Colors.white; // Dark mode text

  void _navigateToEdit(Tree tree) async {
    final vm = context.read<TreeListViewModel>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TreeDetailScreen(tree: tree)),
    );
    if (result == true) {
      vm.fetchTrees();
    }
  }

  Future<void> _handleExport() async {
    final vm = context.read<TreeListViewModel>();
    final csvData = await vm.exportData();
    if (csvData != null) {
      if (kIsWeb) {
        WebUtils.downloadFile(
          csvData,
          "trees_export_${DateTime.now().millisecondsSinceEpoch}.csv",
        );
      } else {
        debugPrint('CSV Export is only supported on Web currently.');
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('수목 데이터가 다운로드되었습니다.')));
      }
    }
  }

  Future<void> _handleImport() async {
    final vm = context.read<TreeListViewModel>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final results = await vm.importData(file.bytes!, file.name);

      if (mounted && results != null) {
        final success = results['success'] ?? 0;
        final failed = results['failed'] ?? 0;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('가져오기 완료'),
            content: Text('성공: $success건\n실패: $failed건'),
            backgroundColor: const Color(0xFF15281E),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            contentTextStyle: const TextStyle(color: Colors.white70),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeListViewModel>();

    // Force Dark Mode for Admin App consistency
    const bgColor = backgroundDark;
    const textColor = textLight;
    const subTextColor = Color(0xFF618975);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: textColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '수목도감 일람',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'export') {
                        _handleExport();
                      } else if (value == 'import') {
                        _handleImport();
                      }
                    },
                    icon: const Icon(Icons.more_vert, color: textColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 20),
                            SizedBox(width: 8),
                            Text('데이터 내보내기 (CSV)'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'import',
                        child: Row(
                          children: [
                            Icon(Icons.upload, size: 20),
                            SizedBox(width: 8),
                            Text('데이터 가져오기 (CSV)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: vm.search,
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: '수목명 또는 학명 검색...',
                  hintStyle: const TextStyle(color: subTextColor),
                  prefixIcon: const Icon(Icons.search, color: subTextColor),
                  filled: true,
                  fillColor: const Color(0xFF1A2E24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // 4. Filters
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...TreeListViewModel.categories.map((category) {
                    final isSelected = vm.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => vm.filterByCategory(category),
                        borderRadius: BorderRadius.circular(20),
                        child: _buildFilterChip(
                          category,
                          isSelected,
                          primaryColor,
                          textColor,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 5. Total Count & Pagination
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF15281E),
                border: Border(
                  bottom: BorderSide(color: Colors.white10, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '수목 현황',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '총 ${vm.filteredTotalCount}건',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // First Page
                        _buildPageAction(
                          icon: Icons.first_page,
                          onTap: vm.currentPage > 1
                              ? () => vm.setPage(1)
                              : null,
                          enabled: vm.currentPage > 1,
                        ),
                        // Previous
                        _buildPageAction(
                          icon: Icons.chevron_left,
                          onTap: vm.currentPage > 1 ? vm.previousPage : null,
                          enabled: vm.currentPage > 1,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '${vm.currentPage} / ${vm.totalPages}',
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Next
                        _buildPageAction(
                          icon: Icons.chevron_right,
                          onTap: vm.currentPage < vm.totalPages
                              ? vm.nextPage
                              : null,
                          enabled: vm.currentPage < vm.totalPages,
                        ),
                        // Last Page
                        _buildPageAction(
                          icon: Icons.last_page,
                          onTap: vm.currentPage < vm.totalPages
                              ? () => vm.setPage(vm.totalPages)
                              : null,
                          enabled: vm.currentPage < vm.totalPages,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 6. List
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : ListView.separated(
                      itemCount: vm.trees.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Colors.white10),
                      itemBuilder: (context, index) {
                        final tree = vm.trees[index];
                        return _buildListItem(
                          tree,
                          textColor,
                          subTextColor,
                          primaryColor,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageAction({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: enabled ? textLight : Colors.white10, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Color primary,
    Color textColor,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    Tree tree,
    Color textColor,
    Color subTextColor,
    Color primary,
  ) {
    // Mock status logic
    const status = '게시됨';
    final statusColor = primary;
    final statusBg = primary.withValues(alpha: 0.2);

    return InkWell(
      onTap: () => _navigateToEdit(tree),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail Removed

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tree.nameKr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!tree.isAutoQuizEnabled) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            '비교전용',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Category Tags
                      if (tree.category != null && tree.category!.isNotEmpty)
                        ...tree.category!
                            .split('/')
                            .map((c) => _buildSmallTag(c.trim(), primary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Scientific Name Removed
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildCountBadge(
                        icon: Icons.image_outlined,
                        count: tree.images.length,
                        color: Colors.blueAccent.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 12),
                      _buildCountBadge(
                        icon: Icons.lightbulb_outline,
                        count: tree.images
                            .where(
                              (img) => img.hint != null && img.hint!.isNotEmpty,
                            )
                            .length,
                        color: Colors.orangeAccent.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => _showDeleteDialog(tree),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
            Icon(Icons.chevron_right, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBadge({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTag(String label, Color primary) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: primary.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: primary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(Tree tree) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수목 삭제'),
        content: Text('${tree.nameKr} 수목을(를) 정말 삭제하시겠습니까?'),
        backgroundColor: const Color(0xFF15281E),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        contentTextStyle: const TextStyle(color: Colors.white70),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vm = context.read<TreeListViewModel>();
      await vm.deleteTree(tree.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('삭제되었습니다.')));
      }
    }
  }
}
