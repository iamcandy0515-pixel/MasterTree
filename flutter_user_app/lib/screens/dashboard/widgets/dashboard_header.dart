import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../login_screen.dart';
import '../../notification_screen.dart';

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
        onPressed: () => Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()),
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
      actions: [
        IconButton(
          onPressed: () => Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (context) => const NotificationScreen()),
          ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textLight,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

