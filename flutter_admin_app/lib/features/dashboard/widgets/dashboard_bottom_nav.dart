import 'dart:ui';
import 'package:flutter/material.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const surfaceDark = Color(0xFF1A2E24);
    const primaryColor = Color(0xFF2BEE8C);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: surfaceDark.withValues(alpha: 0.85),
            border: const Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                icon: Icons.dashboard,
                label: '홈',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
                primaryColor: primaryColor,
              ),
              _buildNavItem(
                icon: Icons.analytics_outlined,
                label: '통계',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                primaryColor: primaryColor,
              ),
              _buildNavItem(
                icon: Icons.people_outlined,
                label: '사용자',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                primaryColor: primaryColor,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                label: '설정',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey[600],
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
