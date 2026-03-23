import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_selection_modal_viewmodel.dart';

class TreeCategoryFilters extends StatelessWidget {
  final TreeSelectionModalViewModel vm;

  const TreeCategoryFilters({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildFilterChip(context, '침엽수'),
          const SizedBox(width: 8),
          _buildFilterChip(context, '활엽수'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final isSelected = vm.selectedCategory == label;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selectedColor: NeoColors.acidLime,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? NeoColors.acidLime : Colors.white30,
        ),
      ),
      onSelected: (selected) {
        vm.setCategory(selected ? label : null);
      },
    );
  }
}
