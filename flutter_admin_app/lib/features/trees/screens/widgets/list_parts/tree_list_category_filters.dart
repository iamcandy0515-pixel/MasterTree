import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_list_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class TreeListCategoryFilters extends StatelessWidget {
  const TreeListCategoryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeListViewModel>();
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TreeListViewModel.categories.length,
        itemBuilder: (context, index) {
          final category = TreeListViewModel.categories[index];
          final isSelected = vm.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => vm.filterByCategory(category),
              borderRadius: BorderRadius.circular(20),
              child: _FilterChip(label: category, isSelected: isSelected),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    const primary = NeoColors.acidLime;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: primary),
            ],
          ],
        ),
      ),
    );
  }
}

