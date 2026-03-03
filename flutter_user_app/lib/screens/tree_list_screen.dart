import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/controllers/tree_list_controller.dart';
import 'package:flutter_user_app/core/widgets/fullscreen_image_viewer.dart';

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
          _buildHeader(context),
          Expanded(
            child: _controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _controller.filteredTrees.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildPaginationNavigator(),
                          const SizedBox(height: 8),
                          _buildTreeTextList(context),
                          const SizedBox(height: 120), // Bottom nav space
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.forest_outlined,
          size: 64,
          color: AppColors.textMuted.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        const Text(
          '등록된 수목이 없습니다.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                const Text(
                  '수목 도감 상세',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(
                  width: 40,
                ), // Balanced space for the removed menu 버튼
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildFilterChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textLight, size: 20),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        // Auto-switch to '전체' when searching
        if (value.isNotEmpty && _controller.selectedCategory != '전체') {
          _controller.selectedCategory = '전체';
        }
        setState(() {}); // Update UI for clear button
        _controller.filterTrees(value, () => setState(() {}));
      },
      style: const TextStyle(color: AppColors.textLight, fontSize: 14),
      decoration: InputDecoration(
        hintText: '나무 검색',
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                  _controller.filterTrees('', () => setState(() {}));
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['전체', '침엽수', '활엽수', '상록수', '낙엽수'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters
            .map(
              (f) => _buildChip(f, isActive: f == _controller.selectedCategory),
            )
            .toList(),
      ),
    );
  }

  Widget _buildChip(String label, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          _controller.changeCategory(
            label,
            _searchController.text,
            () => setState(() {}),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.black
                  : AppColors.textLight.withOpacity(0.7),
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationNavigator() {
    final totalPages =
        (_controller.filteredTrees.length / TreeListController.itemsPerPage)
            .ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page, color: AppColors.primary),
            onPressed: _controller.currentPage > 0
                ? () => _controller.setPage(0, () => setState(() {}))
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: _controller.currentPage > 0
                ? () => _controller.prevPage(() => setState(() {}))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '${_controller.currentPage + 1} / $totalPages',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: _controller.currentPage < totalPages - 1
                ? () => _controller.nextPage(() => setState(() {}))
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page, color: AppColors.primary),
            onPressed: _controller.currentPage < totalPages - 1
                ? () =>
                      _controller.setPage(totalPages - 1, () => setState(() {}))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTreeTextList(BuildContext context) {
    final startIndex =
        _controller.currentPage * TreeListController.itemsPerPage;
    final pagedTrees = _controller.filteredTrees
        .skip(startIndex)
        .take(TreeListController.itemsPerPage)
        .toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pagedTrees.length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
      itemBuilder: (context, index) {
        final tree = pagedTrees[index];
        final name = tree['name_kr'] ?? '이름 없음';
        final category = tree['category'] ?? '-';

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
                            name,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textMuted,
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTreeDetail(BuildContext context, Map<String, dynamic> tree) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TreeDetailSheet(tree: tree),
    );
  }
}

class _TreeDetailSheet extends StatefulWidget {
  final Map<String, dynamic> tree;
  const _TreeDetailSheet({required this.tree});

  @override
  State<_TreeDetailSheet> createState() => _TreeDetailSheetState();
}

class _TreeDetailSheetState extends State<_TreeDetailSheet> {
  String _selectedTag = '대표';
  Map<String, Map<String, String?>> _imageData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImageData();
  }

  Future<void> _loadImageData() async {
    try {
      final imageData = TreeListController.processImageData(widget.tree);

      setState(() {
        _imageData = imageData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error processing image data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 12),
          _buildTopNavigation(), // Horizontal navigation at the top
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainImage(),
                        const SizedBox(height: 24),
                        _buildHint(),
                        const SizedBox(height: 24),
                        _buildDetails(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    final name = widget.tree['name_kr'] ?? '이름 없음';
    final scientificName = widget.tree['scientific_name'] ?? 'N/A';

    // Get image URL for selected tag
    final imageUrl = ApiService.getProxyImageUrl(
      _imageData[_selectedTag]?['image_url'] ??
          'https://picsum.photos/seed/${widget.tree['id']}/600/600',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 1.0, // Square ratio for clear detail viewing
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.02),
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullscreenImageViewer(
                    imageUrl: imageUrl,
                    title: '$name ($_selectedTag)',
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 800, // Downscale for memory efficiency
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        scientificName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    final tags = ['대표', '잎', '수피', '꽃', '열매/겨울눈'];
    return Container(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tags.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final t = tags[index];
          final isSelected = t == _selectedTag;
          return GestureDetector(
            onTap: () => setState(() => _selectedTag = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.5)
                      : Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  t,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHint() {
    final hint = _imageData[_selectedTag]?['hint'];

    if (hint == null || hint.isEmpty || hint == '자료없음') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_selectedTag 힌트가 등록되지 않았습니다.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_selectedTag 힌트',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final category = widget.tree['category'] ?? '미분류';
    final shape = widget.tree['shape'] ?? '정보 없음';
    final description = widget.tree['description'] ?? '상세 설명이 등록되지 않았습니다.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildDetailRow(Icons.category, '구분', category),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.filter_vintage, '수형', shape),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.description, '상세 설명', description),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
