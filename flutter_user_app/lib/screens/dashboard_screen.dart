import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';

import 'package:flutter_user_app/screens/quiz_screen.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';

import 'package:flutter_user_app/controllers/dashboard_controller.dart';
import 'dashboard/widgets/dashboard_header.dart';
import 'dashboard/widgets/dashboard_stats_section.dart';
import 'dashboard/widgets/dashboard_tree_tab.dart';
import 'dashboard/widgets/dashboard_exam_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final DashboardController _controller = DashboardController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller.init(() => setState(() {}));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            
            // TabBar section
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.textLight,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: '수목관리'),
                    Tab(text: '기출문제'),
                  ],
                  onTap: (index) => setState(() {}),
                ),
              ),
            ),

            // Tab content
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  return _tabController.index == 0
                      ? const DashboardTreeTab()
                      : const DashboardExamTab();
                },
              ),
            ),
            
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
            // 메인 대시보드 (이미 현재 화면인 경우 스크롤 업 등 처리 가능)
          } else if (index == index) {
             // 기존 네비게이션 로직 유지 (기출/수목/통계)
             // 하지만 대시보드 내에 탭이 생겼으므로 하단 네비게이션의 역할을 재검토할 필요가 있음.
             // 계획서에는 하단 네비게이션 변경은 언급되지 않았으므로 그대로 둡니다.
          }

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            ).then((_) => setState(() => _controller.currentIndex = 0));
          } else if (index == 2) {
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
            icon: Icon(Icons.dashboard_outlined),
            label: '대시보드',
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundDark,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
