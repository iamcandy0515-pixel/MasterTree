import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../core/api_service.dart';
import '../../../controllers/tree_list_controller.dart';
import '../../../core/widgets/fullscreen_image_viewer.dart';

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
          const Text(
            '수목 상세',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTopNavigation(),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
    final imageUrl = ApiService.getProxyImageUrl(
      _imageData[_selectedTag]?['image_url'] ?? 'https://picsum.photos/seed/${widget.tree['id']}/600/600',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 1.0,
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
                  cacheWidth: 800,
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
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
                const Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(Icons.zoom_in, color: Colors.white, size: 24),
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
                        style: const TextStyle(color: AppColors.textLight, fontSize: 28, fontWeight: FontWeight.bold),
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
    return SizedBox(
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
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
          ),
          child: Text('$_selectedTag 파트가 없습니다.', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
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
        child: Text(hint, style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.5)),
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildDetailRow(Icons.category, '구분', widget.tree['category'] ?? '미분류'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.filter_vintage, '수형', widget.tree['shape'] ?? '정보 없음'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.description, '상세 설명', widget.tree['description'] ?? '설명 없음'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}

