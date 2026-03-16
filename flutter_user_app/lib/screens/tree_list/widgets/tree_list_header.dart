import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../controllers/tree_list_controller.dart';

class TreeListHeader extends StatelessWidget {
  final TreeListController controller;
  final TextEditingController searchController;
  final VoidCallback onUpdate;

  const TreeListHeader({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                _buildCircleButton(
                  Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '수목도감 알람',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildFilterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textLight, size: 20),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        controller.filterTrees(value, onUpdate);
      },
      style: const TextStyle(color: AppColors.textLight, fontSize: 14),
      decoration: InputDecoration(
        hintText: '나무 이름 검색',
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 20),
                onPressed: () {
                  searchController.clear();
                  controller.filterTrees('', onUpdate);
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: '침엽/활엽',
            value: controller.selectedType,
            items: ['전체', '침엽수', '활엽수'],
            onChanged: (val) {
              if (val != null) controller.changeType(val, searchController.text, onUpdate);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            label: '상록/낙엽',
            value: controller.selectedHabit,
            items: ['전체', '상록수', '낙엽수'],
            onChanged: (val) {
              if (val != null) controller.changeHabit(val, searchController.text, onUpdate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.surfaceDark,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
              style: const TextStyle(color: AppColors.textLight, fontSize: 13),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

