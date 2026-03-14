import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/similar_species_controller.dart';
import 'similar_species/widgets/similar_species_header.dart';
import 'similar_species/widgets/similar_species_card.dart';

class SimilarSpeciesListScreen extends StatefulWidget {
  const SimilarSpeciesListScreen({super.key});

  @override
  State<SimilarSpeciesListScreen> createState() => _SimilarSpeciesListScreenState();
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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          const SimilarSpeciesHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  _controller.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _buildComparisonList(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _controller.updateSearchQuery(value, onUpdate: () => setState(() {})),
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

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPagination(),
        Text(
          '총 ${_controller.totalFilteredResults}개',
          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    if (_controller.totalPages <= 1) return const SizedBox.shrink();
    return Row(
      children: [
        _buildPageNavButton(Icons.first_page, _controller.currentPage > 1, 
            () => _controller.setPage(1, onUpdate: () => setState(() {}))),
        const SizedBox(width: 4),
        _buildPageNavButton(Icons.chevron_left, _controller.currentPage > 1, 
            () => _controller.prevPage(onUpdate: () => setState(() {}))),
        const SizedBox(width: 12),
        Text('${_controller.currentPage} / ${_controller.totalPages}',
            style: const TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        _buildPageNavButton(Icons.chevron_right, _controller.currentPage < _controller.totalPages,
            () => _controller.nextPage(onUpdate: () => setState(() {}))),
        const SizedBox(width: 4),
        _buildPageNavButton(Icons.last_page, _controller.currentPage < _controller.totalPages,
            () => _controller.setPage(_controller.totalPages, onUpdate: () => setState(() {}))),
      ],
    );
  }

  Widget _buildPageNavButton(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: enabled ? AppColors.textLight : Colors.white10, size: 20),
      ),
    );
  }

  Widget _buildComparisonList() {
    final list = _controller.displayList;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => SimilarSpeciesCard(item: list[index]),
    );
  }
}
