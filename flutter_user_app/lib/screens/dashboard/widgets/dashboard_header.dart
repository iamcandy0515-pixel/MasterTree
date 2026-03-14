import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../login_screen.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
      floating: true,
      pinned: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '사용자 대시보드',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Master Tree User',
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: const [
        SizedBox(width: 12),
      ],
    );
  }
}
