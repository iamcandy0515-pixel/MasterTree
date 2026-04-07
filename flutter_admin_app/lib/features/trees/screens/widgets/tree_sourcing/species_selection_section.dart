import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/tree_sourcing_viewmodel.dart';
import '../../../models/tree.dart';
import '../../tree_sourcing_detail_screen.dart';

class SpeciesSelectionSection extends StatelessWidget {
  final Color primaryColor;
  final Color backgroundDark;

  const SpeciesSelectionSection({
    super.key,
    required this.primaryColor,
    required this.backgroundDark,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TreeSourcingViewModel>(context);

    return Column(
      children: [
        // 상단 페이지네이션 컨트롤
        if (vm.trees.isNotEmpty && !vm.isLoading) ...[
          _buildPaginationControls(vm),
          const SizedBox(height: 16),
        ],

        // 나무 리스트
        if (vm.isLoading)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: Color(0xFF2BEE8C)),
          )
        else if (vm.trees.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.trees.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tree = vm.trees[index];
              return _buildTreeCard(context, tree, vm);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          Icon(Icons.search_off, color: Colors.grey, size: 40),
          SizedBox(height: 12),
          Text('조회된 수목이 없습니다.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTreeCard(
    BuildContext context,
    Tree tree,
    TreeSourcingViewModel vm,
  ) {
    return InkWell(
      onTap: () async {
        final dynamic result = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) => ChangeNotifierProvider.value(
              value: vm,
              child: TreeSourcingDetailScreen(tree: tree),
            ),
          ),
        );
        if (result == true) {
          vm.loadTrees(page: vm.currentPage);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tree.nameKr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tree.scientificName} / ${tree.category}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusIcons(tree),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcons(Tree tree) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(Icons.eco, '잎', _hasImage(tree, 'leaf')),
        _buildIcon(Icons.texture, '수피', _hasImage(tree, 'bark')),
        _buildIcon(Icons.grain, '열매', _hasImage(tree, 'fruit')),
        _buildIcon(Icons.filter_vintage, '꽃', _hasImage(tree, 'flower')),
        _buildIcon(Icons.forest, '전경', _hasImage(tree, 'main')),
      ],
    );
  }

  bool _hasImage(Tree tree, String type) {
    return tree.images.any(
      (img) => img.imageType == type && img.imageUrl.isNotEmpty,
    );
  }

  Widget _buildIcon(IconData icon, String label, bool active) {
    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          icon,
          size: 16,
          color: active ? primaryColor : Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(TreeSourcingViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: vm.currentPage > 1 ? () => vm.loadTrees(page: 1) : null,
          icon: const Icon(Icons.keyboard_double_arrow_left, size: 18),
          color: primaryColor,
        ),
        IconButton(
          onPressed: vm.currentPage > 1 ? () => vm.previousPage() : null,
          icon: const Icon(Icons.keyboard_arrow_left, size: 18),
          color: primaryColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${vm.currentPage} / ${vm.totalPages == 0 ? 1 : vm.totalPages}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: vm.hasMore ? () => vm.nextPage() : null,
          icon: const Icon(Icons.keyboard_arrow_right, size: 18),
          color: primaryColor,
        ),
        IconButton(
          onPressed: vm.currentPage < vm.totalPages
              ? () => vm.loadTrees(page: vm.totalPages)
              : null,
          icon: const Icon(Icons.keyboard_double_arrow_right, size: 18),
          color: primaryColor,
        ),
      ],
    );
  }
}

