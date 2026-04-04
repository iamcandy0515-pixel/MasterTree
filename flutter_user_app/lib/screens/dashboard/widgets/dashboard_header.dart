import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../login_screen.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
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
        children: const [
          Text(
            '사용자 대시보드',
            style: AppTypography.titleSmall,
          ),
          Text(
            'Master Tree User',
            style: AppTypography.labelSmall,
          ),
        ],
      ),
      actions: const [
        SizedBox(width: 12),
      ],
    );
  }
}

