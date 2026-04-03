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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundDark,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

