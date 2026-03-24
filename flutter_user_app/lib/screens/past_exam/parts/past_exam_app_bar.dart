import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';

/// Past Exam Detail App Bar (Strategy: Encapsulated Sync Logic)
/// Adheres to technical spec by focusing sync logic in a dedicated component.
class PastExamAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PastExamAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('기출 / 학습 상세'),
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () async {
          await ApiService.syncPendingAttempts();
          if (context.mounted) Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await ApiService.syncPendingAttempts();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const UserStatsScreen(initialIndex: 2),
                ),
              );
            }
          },
          child: const Text(
            '학습통계',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
