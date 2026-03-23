import 'package:flutter/material.dart';
import '../../../viewmodels/tree_lookalike_viewmodel.dart';

class LookalikeTabSelector extends StatelessWidget {
  final TreeLookalikeViewModel vm;
  const LookalikeTabSelector({super.key, required this.vm});

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
