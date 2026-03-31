import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/controllers/tree_list_controller.dart';
import 'detail/tree_part_selector.dart';
import 'detail/tree_hero_section.dart';
import 'detail/tree_attribute_row.dart';
import 'detail/tree_detail_skeleton.dart';

class TreeDetailSheet extends StatefulWidget {
  final Map<String, dynamic> tree;
  const TreeDetailSheet({super.key, required this.tree});

  @override
  State<TreeDetailSheet> createState() => _TreeDetailSheetState();
}

class _TreeDetailSheetState extends State<TreeDetailSheet> {
  String _selectedTag = '대표';
  Map<String, Map<String, String?>> _imageData = {};
  bool _isLoading = true;
  final List<String> _tags = ['대표', '잎', '수피', '꽃', '열매/겨울눈'];

  @override
  void initState() {
    super.initState();
    _loadImageData();
  }

  Future<void> _loadImageData() async {
    try {
      final imageData = TreeListController.processImageData(widget.tree);
      _imageData = imageData;
      
      // [최적화] 모든 원본 로드 대신 썸네일 또는 초경량 리사이징 프리칭
      if (mounted) {
        for (var tag in _tags) {
          final urlData = _imageData[tag];
          // 썸네일이 있으면 최우선, 없으면 200px 리사이징으로 아주 가볍게 로드
          final thumbUrl = urlData?['thumbnail_url'] ?? urlData?['image_url'];
          
          if (thumbUrl != null) {
            precacheImage(
              NetworkImage(ApiService.getProxyImageUrl(thumbUrl, width: 200)),
              context,
            );
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error processing image data: $e');
      if (mounted) setState(() => _isLoading = false);
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
          _buildHandle(),
          const SizedBox(height: 16),
          const Text(
            '수목 상세',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 12),
          TreePartSelector(
            tags: _tags,
            selectedTag: _selectedTag,
            onTagSelected: (tag) => setState(() => _selectedTag = tag),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading 
                ? const TreeDetailSkeleton()
                : SingleChildScrollView(
                    key: ValueKey(_selectedTag),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TreeHeroSection(
                          name: widget.tree['name_kr'] ?? '이름 없음',
                          scientificName: widget.tree['scientific_name'] ?? 'N/A',
                          // [최적화] 기기 너비에 최적화된 리사이징 URL 요청 (600px)
                          imageUrl: ApiService.getProxyImageUrl(
                            _imageData[_selectedTag]?['image_url'] ?? 
                            'https://picsum.photos/seed/${widget.tree['id']}/600/600',
                            width: 600,
                          ),
                          tag: _selectedTag,
                        ),
                        const SizedBox(height: 24),
                        _buildHint(),
                        const SizedBox(height: 24),
                        _buildDetailsList(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHint() {
    final hint = _imageData[_selectedTag]?['hint'];
    final bool isEmpty = hint == null || hint.isEmpty || hint == '자료없음';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.white.withOpacity(0.03) : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          isEmpty ? '$_selectedTag 파트가 없습니다.' : hint,
          style: TextStyle(
            color: isEmpty ? AppColors.textMuted : AppColors.textLight,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TreeAttributeRow(
            icon: Icons.category,
            label: '구분',
            content: widget.tree['category'] ?? '미분류',
          ),
          const SizedBox(height: 16),
          TreeAttributeRow(
            icon: Icons.filter_vintage,
            label: '수형',
            content: widget.tree['shape'] ?? '정보 없음',
          ),
          const SizedBox(height: 16),
          TreeAttributeRow(
            icon: Icons.description,
            label: '상세 설명',
            content: widget.tree['description'] ?? '설명 없음',
          ),
        ],
      ),
    );
  }
}
