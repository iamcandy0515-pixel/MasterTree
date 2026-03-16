import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../controllers/tree_list_controller.dart';

class TreeListPagination extends StatelessWidget {
  final TreeListController controller;
  final VoidCallback onUpdate;

  const TreeListPagination({
    super.key,
    required this.controller,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (controller.filteredTrees.length / TreeListController.itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageButton(Icons.first_page, controller.currentPage > 0, 
            () => controller.setPage(0, onUpdate)),
          _buildPageButton(Icons.chevron_left, controller.currentPage > 0, 
            () => controller.prevPage(onUpdate)),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${controller.currentPage + 1} / $totalPages',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          _buildPageButton(Icons.chevron_right, controller.currentPage < totalPages - 1, 
            () => controller.nextPage(onUpdate)),
          _buildPageButton(Icons.last_page, controller.currentPage < totalPages - 1, 
            () => controller.setPage(totalPages - 1, onUpdate)),
        ],
      ),
    );
  }

  Widget _buildPageButton(IconData icon, bool enabled, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: enabled ? AppColors.primary : AppColors.textMuted.withOpacity(0.2)),
      onPressed: enabled ? onTap : null,
      iconSize: 24,
    );
  }
}

