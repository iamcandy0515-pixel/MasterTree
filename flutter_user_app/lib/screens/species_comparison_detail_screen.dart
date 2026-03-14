import 'package:flutter/material.dart';
import '../core/design_system.dart';
import '../controllers/species_comparison_detail_controller.dart';
import '../core/widgets/fullscreen_image_viewer.dart';

class SpeciesComparisonDetailScreen extends StatefulWidget {
  final String tree1;
  final String tree2;
  final String? groupId;

  const SpeciesComparisonDetailScreen({
    super.key,
    required this.tree1,
    required this.tree2,
    this.groupId,
  });

  @override
  State<SpeciesComparisonDetailScreen> createState() =>
      _SpeciesComparisonDetailScreenState();
}

class _SpeciesComparisonDetailScreenState
    extends State<SpeciesComparisonDetailScreen> {
  final SpeciesComparisonDetailController _controller =
      SpeciesComparisonDetailController();

  @override
  void initState() {
    super.initState();
    _controller.fetchDetailData(
      tree1: widget.tree1,
      tree2: widget.tree2,
      groupId: widget.groupId,
      onUpdate: () => setState(() {}),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '화면 하단 아래에 비교 이미지(수피,잎) 가 있습니다',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.surfaceDark,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '[DEBUG] build() called. isDataLoading: ${_controller.isDataLoading}, groupData exists: ${_controller.groupData != null}',
    );
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _controller.isDataLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildDetailDataSection(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildVisualComparison(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textLight,
                  size: 24,
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    '유사 수목 상세',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balancing back button width
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    bool isSelected = _controller.selectedTag == label;
    return GestureDetector(
      onTap: () =>
          _controller.setSelectedTag(label, onUpdate: () => setState(() {})),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.backgroundDark : AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVisualComparison() {
    final url1 = _controller.selectedTag == '잎'
        ? _controller.tree1Data.leafImageUrl
        : _controller.tree1Data.barkImageUrl;
    final url2 = _controller.selectedTag == '잎'
        ? _controller.tree2Data.leafImageUrl
        : _controller.tree2Data.barkImageUrl;

    return Container(
      height: 250, // Fixed height to prevent layout jumps
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildImageHalf(
              widget.tree1,
              url1 ?? 'https://via.placeholder.com/400?text=${widget.tree1}',
              isLeft: true,
            ),
          ),
          const VerticalDivider(width: 2, color: Colors.white12),
          Expanded(
            child: _buildImageHalf(
              widget.tree2,
              url2 ?? 'https://via.placeholder.com/400?text=${widget.tree2}',
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHalf(String name, String imageUrl, {required bool isLeft}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullscreenImageViewer(imageUrl: imageUrl, title: name),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              cacheWidth: 500, // Downscale for memory efficiency (half screen)
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.white.withValues(alpha: 0.05),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white.withValues(alpha: 0.05),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white24,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: isLeft ? 16 : null,
            right: !isLeft ? 16 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: isLeft ? 12 : null,
            left: !isLeft ? 12 : null,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showKeyPointsPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          '핵심 식별 포인트',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            _controller.groupData?['description'] ?? '등록된 핵심 식별 포인트가 없습니다.',
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsButton() {
    return TextButton(
      onPressed: _showKeyPointsPopup,
      child: const Text(
        '핵심 식별 포인트',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildDetailDataSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildTag('수피'),
                const SizedBox(width: 12),
                _buildTag('잎'),
              ],
            ),
            _buildKeyPointsButton(),
          ],
        ),
        const SizedBox(height: 8),
        _buildComparisonCard(
          icon: Icons.park,
          title: '잎의 특징',
          content1: _controller.tree1Data.leafHint,
          content2: _controller.tree2Data.leafHint,
        ),
        _buildComparisonCard(
          icon: Icons.texture,
          title: '수피',
          content1: _controller.tree1Data.barkHint,
          content2: _controller.tree2Data.barkHint,
        ),
        _buildComparisonCard(
          icon: Icons.eco,
          title: '꽃·열매 및 겨울눈',
          content1: _controller.tree1Data.etcHint,
          content2: _controller.tree2Data.etcHint,
        ),
      ],
    );
  }

  Widget _buildComparisonCard({
    required IconData icon,
    required String title,
    required String content1,
    required String content2,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDataColumn(widget.tree1, content1)),
                Container(
                  width: 1,
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(child: _buildDataColumn(widget.tree2, content2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataColumn(String treeName, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          treeName,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.isEmpty || value == '상세 정보가 없습니다.' ? '정보가 없습니다.' : value,
          style: TextStyle(
            color:
                value.isEmpty || value == '상세 정보가 없습니다.' || value == '정보가 없습니다.'
                ? AppColors.textMuted
                : Colors.white,
            fontSize: 13,
            height: 1.4,
          ),
          softWrap: true,
        ),
      ],
    );
  }
}
