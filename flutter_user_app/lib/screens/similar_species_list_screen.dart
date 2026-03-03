import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/screens/species_comparison_detail_screen.dart';
import 'package:flutter_user_app/controllers/similar_species_controller.dart';

class SimilarSpeciesListScreen extends StatefulWidget {
  const SimilarSpeciesListScreen({super.key});

  @override
  State<SimilarSpeciesListScreen> createState() =>
      _SimilarSpeciesListScreenState();
}

class _SimilarSpeciesListScreenState extends State<SimilarSpeciesListScreen> {
  final SimilarSpeciesController _controller = SimilarSpeciesController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _controller.loadSavedState();
    if (mounted) {
      _searchController.text = _controller.searchQuery;
      _controller.fetchGroups(onUpdate: () => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _controller.displayList;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    _controller.totalFilteredResults,
                    _controller.totalPages,
                  ),
                  const SizedBox(height: 12),
                  if (_controller.isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  else
                    _buildComparisonList(displayList),
                  const SizedBox(height: 32),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textLight,
                  size: 24,
                ),
              ),
              const Text(
                '유사수목 일람',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(
                width: 48,
              ), // Keep balance after removing more_vert
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _controller.updateSearchQuery(
          value,
          onUpdate: () => setState(() {}),
        ),
        style: const TextStyle(color: AppColors.textLight, fontSize: 14),
        decoration: const InputDecoration(
          hintText: '비교하고 싶은 수종 검색',
          hintStyle: TextStyle(color: AppColors.textMuted),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int totalCount, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPagination(totalPages),
          Text(
            '총 $totalCount개',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonList(List<Map<String, dynamic>> list) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildComparisonCard(context, item);
      },
    );
  }

  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 맨 처음으로
        _buildPageNavButton(
          icon: Icons.first_page,
          isEnabled: _controller.currentPage > 1,
          onTap: () => _controller.setPage(1, onUpdate: () => setState(() {})),
        ),
        // 이전 페이지
        _buildPageNavButton(
          icon: Icons.chevron_left,
          isEnabled: _controller.currentPage > 1,
          onTap: () => _controller.prevPage(onUpdate: () => setState(() {})),
        ),
        const SizedBox(width: 12),
        Text(
          '${_controller.currentPage} / $totalPages',
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        // 다음 페이지
        _buildPageNavButton(
          icon: Icons.chevron_right,
          isEnabled: _controller.currentPage < totalPages,
          onTap: () => _controller.nextPage(onUpdate: () => setState(() {})),
        ),
        // 맨 마지막으로
        _buildPageNavButton(
          icon: Icons.last_page,
          isEnabled: _controller.currentPage < totalPages,
          onTap: () =>
              _controller.setPage(totalPages, onUpdate: () => setState(() {})),
        ),
      ],
    );
  }

  Widget _buildPageNavButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isEnabled ? AppColors.textLight : Colors.white10,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, Map<String, dynamic> item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpeciesComparisonDetailScreen(
              tree1: item['tree1']!,
              tree2: item['tree2']!,
              groupId: item['id'].toString(),
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              _buildImageStack(item['img1']!, item['img2']!),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['group_name'] ??
                          '${item['tree1']} vs ${item['tree2']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['desc']!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageStack(String img1, String img2) {
    return SizedBox(
      width: 64,
      height: 40,
      child: Stack(
        children: [_buildCircleAvatar(0, img1), _buildCircleAvatar(1, img2)],
      ),
    );
  }

  Widget _buildCircleAvatar(int index, String url) {
    return Positioned(
      left: index * 24.0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.backgroundDark, width: 2),
          image: url.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                  onError: (e, s) =>
                      const AssetImage('assets/images/placeholder.png'),
                )
              : null,
          color: Colors.white.withOpacity(0.05),
        ),
        child: url.isEmpty
            ? const Center(
                child: Icon(Icons.park, size: 24, color: Colors.white10),
              )
            : null,
      ),
    );
  }
}
