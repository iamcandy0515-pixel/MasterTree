import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/controllers/tree_list_controller.dart';
import 'detail/tree_part_selector.dart';
import 'detail/tree_hero_section.dart';
import 'detail/tree_part_content.dart';
import 'detail/tree_detail_skeleton.dart';

class TreeDetailSheet extends StatefulWidget {
  final Map<String, dynamic> tree;
  const TreeDetailSheet({super.key, required this.tree});

  @override
  State<TreeDetailSheet> createState() => _TreeDetailSheetState();
}

class _TreeDetailSheetState extends State<TreeDetailSheet> {
  String _selectedTag = '대표';
  Map<String, dynamic>? _fullTree;
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
      final dynamic treeId = widget.tree['id'];
      if (treeId == null) throw Exception('Tree ID is missing');

      // [방식 A] 서버에서 상세 정보를 다시 가져옵니다 (이미지 및 힌트 포함)
      final Map<String, dynamic>? fullTree = await ApiService.getTreeOne(treeId as int);
      
      if (mounted) {
        if (fullTree != null) {
          _fullTree = fullTree;
          _imageData = TreeListController.processImageData(fullTree);
          
          // 가벼운 로딩을 위해 썸네일 프리칭
          for (final String tag in _tags) {
            final String? thumbUrl = _imageData[tag]?['thumbnail_url'] ?? _imageData[tag]?['image_url'];
            if (thumbUrl != null) {
              precacheImage(NetworkImage(ApiService.getProxyImageUrl(thumbUrl, width: 200)), context);
            }
          }
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading tree details: $e');
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
            onTagSelected: (String tag) => setState(() => _selectedTag = tag),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading 
                ? const TreeDetailSkeleton()
                : SingleChildScrollView(
                    key: ValueKey<String>(_selectedTag),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TreeHeroSection(
                          name: ((_fullTree ?? widget.tree)['name_kr'] as String?) ?? '이름 없음',
                          scientificName: ((_fullTree ?? widget.tree)['scientific_name'] as String?) ?? 'N/A',
                          imageUrl: ApiService.getProxyImageUrl(
                            _imageData[_selectedTag]?['image_url'] ?? 
                            'https://picsum.photos/seed/${widget.tree['id']}/600/600',
                            width: 600,
                          ),
                          tag: _selectedTag,
                        ),
                        const SizedBox(height: 24),
                        TreePartContent(
                          selectedTag: _selectedTag,
                          hint: _imageData[_selectedTag]?['hint'],
                          tree: _fullTree ?? widget.tree,
                        ),
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
}
