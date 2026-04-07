import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/dashboard_controller.dart';
import 'package:flutter_user_app/screens/quiz_screen.dart';
import 'package:flutter_user_app/screens/past_exam_list_screen.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';

/// Dashboard Shell Navigation (Strategy: Functional Separation)
/// Decouples main screen layout from bottom navigation and routing logic.
class DashboardBottomNav extends StatelessWidget {
  final DashboardController controller;
  final VoidCallback onUpdate;

  const DashboardBottomNav({
    super.key,
    required this.controller,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex,
        onTap: (int index) {
          controller.currentIndex = index;
          onUpdate();

          if (index == 1) {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (BuildContext context) => const QuizScreen()),
            ).then((dynamic _) {
              controller.currentIndex = 0;
              onUpdate();
            });
          } else if (index == 2) {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (BuildContext context) => const PastExamListScreen()),
            ).then((dynamic _) {
              controller.currentIndex = 0;
              onUpdate();
            });
          } else if (index == 3) {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (BuildContext context) => const UserStatsScreen()),
            ).then((dynamic _) {
              controller.currentIndex = 0;
              onUpdate();
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: '수목/퀴즈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: '기출/학습',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
        ],
      ),
    );
  }
}
