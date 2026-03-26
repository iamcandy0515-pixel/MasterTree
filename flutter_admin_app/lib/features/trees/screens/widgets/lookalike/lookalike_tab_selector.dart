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
        _buildTab(vm, '잎', 'leaf'),
        const SizedBox(width: 12),
        _buildTab(vm, '수피', 'bark'),
        const SizedBox(width: 12),
        _buildTab(vm, '꽃', 'flower'),
        const SizedBox(width: 12),
        _buildTab(vm, '열매', 'fruit'),
      ],
    );
  }

  Widget _buildTab(TreeLookalikeViewModel vm, String label, String value) {
    final isSelected = vm.selectedTab == value;
    const primaryColor = Color(0xFF80F20D);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) vm.setSelectedTab(value);
        },
        selectedColor: primaryColor,
        backgroundColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
