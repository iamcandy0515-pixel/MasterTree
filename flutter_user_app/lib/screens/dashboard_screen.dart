import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';

import 'package:flutter_user_app/screens/quiz_screen.dart';
import 'package:flutter_user_app/screens/past_exam_list_screen.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';

import 'package:flutter_user_app/controllers/dashboard_controller.dart';
import 'dashboard/widgets/dashboard_header.dart';
import 'dashboard/widgets/dashboard_stats_section.dart';
import 'dashboard/widgets/dashboard_module_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    _controller.init(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const DashboardHeader(),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ValueListenableBuilder<Map<String, int>>(
              valueListenable: _controller.statsNotifier,
              builder: (context, stats, _) {
                return SliverToBoxAdapter(
                  child: DashboardStatsSection(
                    treeCount: stats['treeCount'] ?? 0,
                    quizCount: stats['quizCount'] ?? 0,
                    similarCount: stats['similarCount'] ?? 0,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: DashboardModuleGrid()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: BottomNavigationBar(
        currentIndex: _controller.currentIndex,
        onTap: (index) {
          setState(() {
            _controller.currentIndex = index;
          });

          if (index == 0) {
            // 기출/퀴즈
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PastExamListScreen()),
            ).then((_) => setState(() => _controller.currentIndex = 0));
          } else if (index == 1) {
            // 수목/퀴즈
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            ).then((_) => setState(() => _controller.currentIndex = 0));
          } else if (index == 2) {
            // 통계
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserStatsScreen()),
            ).then((_) => setState(() => _controller.currentIndex = 0));
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
            icon: Icon(Icons.history_edu),
            label: '기출/퀴즈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: '수목/퀴즈',
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
