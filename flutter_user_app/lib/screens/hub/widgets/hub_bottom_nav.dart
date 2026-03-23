import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/design_system.dart';

class HubBottomNav extends StatelessWidget {
  final VoidCallback? onStatsTap;

  const HubBottomNav({
    super.key,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDesign.glassBlur,
          sigmaY: AppDesign.glassBlur,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _BottomNavItem(
                icon: Icons.grid_view,
                label: '허브',
                isActive: true,
              ),
              const _BottomNavItem(icon: Icons.search, label: '검색'),
              _BottomNavItem(
                icon: Icons.analytics,
                label: '통계',
                onTap: onStatsTap,
              ),
              const _BottomNavItem(icon: Icons.settings, label: '설정'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : Colors.white24,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white24,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
