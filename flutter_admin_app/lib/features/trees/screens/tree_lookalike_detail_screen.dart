import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_lookalike_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TreeLookalikeDetailScreen extends StatelessWidget {
  final TreeGroup group;
  const TreeLookalikeDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeLookalikeViewModel(initialGroup: group),
      child: const _TreeLookalikeDetailContent(),
    );
  }
}

class _TreeLookalikeDetailContent extends StatefulWidget {
  const _TreeLookalikeDetailContent();

  @override
  State<_TreeLookalikeDetailContent> createState() =>
      _TreeLookalikeDetailContentState();
}

class _TreeLookalikeDetailContentState
    extends State<_TreeLookalikeDetailContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<TreeLookalikeViewModel>();
        if (vm.group != null) {
          vm.loadGroupDetail(vm.group!.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeLookalikeViewModel>();
    final group = vm.group;

    if (group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141811), // AppColors.background
      appBar: _buildAppBar(context, group.name),
      body: _ComparisonMatrix(group: group, vm: vm),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _SmartTagsSection extends StatelessWidget {
  final TreeLookalikeViewModel vm;
  const _SmartTagsSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab(vm, '잎 (Leaf)', 'leaf'),
        const SizedBox(width: 16),
        _buildTab(vm, '수피 (Bark)', 'bark'),
      ],
    );
  }

  Widget _buildTab(TreeLookalikeViewModel vm, String label, String value) {
    final isSelected = vm.selectedTab == value;
    const primaryColor = Color(0xFF80F20D);

    return GestureDetector(
      onTap: () => vm.setSelectedTab(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryColor : Colors.white24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ComparisonMatrix extends StatefulWidget {
  final TreeGroup group;
  final TreeLookalikeViewModel vm;

  const _ComparisonMatrix({required this.group, required this.vm});

  @override
  State<_ComparisonMatrix> createState() => _ComparisonMatrixState();
}

class _ComparisonMatrixState extends State<_ComparisonMatrix> {
  final ScrollController _horizontalController = ScrollController();
  final double _columnWidth = 180.0;

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    if (!_horizontalController.hasClients) return;

    if (_horizontalController.offset <=
        _horizontalController.position.minScrollExtent) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('더 이상 이미지 정보가 없습니다.'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentOffset = _horizontalController.offset;
    final targetOffset = (currentOffset - _columnWidth).clamp(
      0.0,
      _horizontalController.position.maxScrollExtent,
    );
    _horizontalController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    if (!_horizontalController.hasClients) return;

    if (_horizontalController.offset >=
        _horizontalController.position.maxScrollExtent) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('더 이상 이미지 정보가 없습니다.'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentOffset = _horizontalController.offset;
    final targetOffset = (currentOffset + _columnWidth).clamp(
      0.0,
      _horizontalController.position.maxScrollExtent,
    );
    _horizontalController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define row heights - Drastically reduced to prevent overflow even on small screens
    const double imageRowHeight = 160;
    const double nameRowHeight = 50;
    const double characteristicRowHeight = 180;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      primary:
          true, // Allow this view to interact with the primary scroll controller
      child: Column(
        children: [
          const SizedBox(height: 16),
          // 1. Tab Selection
          _SmartTagsSection(vm: widget.vm),

          const SizedBox(height: 16),
          // 2. Navigation Controls
          _buildNavigationControls(),

          const SizedBox(height: 16),

          // 3. Matrix Content
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed Label Column
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    border: const Border(
                      right: BorderSide(color: Colors.white10),
                    ),
                  ),
                  // Wrap in ScrollView to prevent overflow error if height is constrained
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildFixedLabelCell(
                          '이미지',
                          height: imageRowHeight,
                          isHeader: true,
                        ),
                        const Divider(height: 1, color: Colors.white10),
                        _buildFixedLabelCell(
                          '수목명',
                          height: nameRowHeight,
                          isHeader: true,
                        ),
                        const Divider(height: 1, color: Colors.white10),
                        _buildFixedLabelCell(
                          '주요 특징\n(Hint)',
                          height: characteristicRowHeight,
                          isHeader: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Scrollable Data Columns
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.group.members.map((member) {
                        return _buildDataColumn(
                          member,
                          imageRowHeight,
                          nameRowHeight,
                          characteristicRowHeight,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.touch_app, color: Colors.white54, size: 14),
                SizedBox(width: 8),
                Text(
                  '가로로 보기',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _NavButton(
            icon: Icons.chevron_left,
            onTap: _scrollLeft,
            color: const Color(0xFF80F20D),
          ),
          const SizedBox(width: 8),
          _NavButton(
            icon: Icons.chevron_right,
            onTap: _scrollRight,
            color: const Color(0xFF80F20D),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedLabelCell(
    String text, {
    double height = 60,
    bool isHeader = false,
  }) {
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: isHeader ? Colors.white.withOpacity(0.02) : null,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataColumn(
    TreeGroupMember member,
    double imgH,
    double nameH,
    double charH,
  ) {
    // Get image based on selected tab
    String? imageUrl;
    if (widget.vm.selectedTab == 'leaf') {
      imageUrl = member.leafImageUrl;
    } else {
      imageUrl = member.barkImageUrl;
    }

    // Get hint logic
    String hintText = '데이터 없음';
    if (widget.vm.selectedTab == 'leaf') {
      hintText =
          member.imageHints['leaf'] ?? member.imageHints['leaves'] ?? '-';
    } else {
      hintText = member.imageHints['bark'] ?? '-';
    }

    return Container(
      width: _columnWidth,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          // Image Cell
          SizedBox(
            height: imgH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  GestureDetector(
                    onTap: () {
                      // Optional: Show full screen image
                    },
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[850],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[850],
                    child: const Center(
                      child: Text(
                        '이미지 없음',
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // Name Cell
          Container(
            height: nameH,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              member.treeName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // Hint Cell (Scrollable vertically if needed)
          Container(
            height: charH,
            padding: const EdgeInsets.all(12),
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              child: Text(
                hintText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _NavButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 20),
      ),
    );
  }
}
