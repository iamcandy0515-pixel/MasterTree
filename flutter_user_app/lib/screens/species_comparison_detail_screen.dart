import 'package:flutter/material.dart';
import '../core/design_system.dart';
import '../controllers/species_comparison_detail_controller.dart';
import 'species_comparison/widgets/comparison_header.dart';
import 'species_comparison/widgets/visual_comparison_section.dart';
import 'species_comparison/widgets/comparison_data_card.dart';

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
  State<SpeciesComparisonDetailScreen> createState() => _SpeciesComparisonDetailScreenState();
}

class _SpeciesComparisonDetailScreenState extends State<SpeciesComparisonDetailScreen> {
  final SpeciesComparisonDetailController _controller = SpeciesComparisonDetailController();

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
            content: const Text('화면 하단에 비교 이미지(수피, 잎)가 있습니다', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.surfaceDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          const ComparisonHeader(),
          Expanded(
            child: _controller.isDataLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildBody(),
                        ),
                        const SizedBox(height: 8),
                        _buildVisualSection(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
        ComparisonDataCard(
          icon: Icons.park,
          title: '잎의 핵심 특징',
          content1: _controller.tree1Data.leafHint,
          content2: _controller.tree2Data.leafHint,
          tree1Name: widget.tree1,
          tree2Name: widget.tree2,
        ),
        ComparisonDataCard(
          icon: Icons.texture,
          title: '수피(나무껍질)',
          content1: _controller.tree1Data.barkHint,
          content2: _controller.tree2Data.barkHint,
          tree1Name: widget.tree1,
          tree2Name: widget.tree2,
        ),
        ComparisonDataCard(
          icon: Icons.eco,
          title: '꽃/열매 및 겨울눈',
          content1: _controller.tree1Data.etcHint,
          content2: _controller.tree2Data.etcHint,
          tree1Name: widget.tree1,
          tree2Name: widget.tree2,
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    bool isSelected = _controller.selectedTag == label;
    return GestureDetector(
      onTap: () => _controller.setSelectedTag(label, onUpdate: () => setState(() {})),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.black : AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildKeyPointsButton() {
    return TextButton(
      onPressed: _showKeyPointsPopup,
      child: const Text('주요 식별 포인트', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
    );
  }

  void _showKeyPointsPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('핵심 요점 식별법', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(_controller.groupData?['description'] ?? '정보가 없습니다.', style: const TextStyle(color: Colors.white, height: 1.5)),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기', style: TextStyle(color: AppColors.primary)))],
      ),
    );
  }

  Widget _buildVisualSection() {
    final url1 = _controller.selectedTag == '잎' ? _controller.tree1Data.leafImageUrl : _controller.tree1Data.barkImageUrl;
    final url2 = _controller.selectedTag == '잎' ? _controller.tree2Data.leafImageUrl : _controller.tree2Data.barkImageUrl;
    return VisualComparisonSection(tree1Name: widget.tree1, tree2Name: widget.tree2, url1: url1, url2: url2);
  }
}

