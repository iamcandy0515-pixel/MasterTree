import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/dashboard_controller.dart';

// Parts
import 'dashboard/widgets/dashboard_header.dart';
import 'dashboard/widgets/dashboard_stats_section.dart';
import 'dashboard/widgets/dashboard_tree_tab.dart';
import 'dashboard/widgets/dashboard_exam_tab.dart';
import 'dashboard/parts/dashboard_bottom_nav.dart';
import 'dashboard/parts/dashboard_tab_section.dart';

/// Main Dashboard Screen (Refactored Strategy: Pure Scaffold)
/// Optimized for Load Balancing & Adheres to Rule 1-1 (<200 lines).
/// Responsibilities split among parts/, widgets/, and utils/.
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
            
            // Statistics Section (ValueListenable for Partial Rebuilds)
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
            
            // Persistent Tab Section (Extracted Strategy: Functional UI)
            DashboardTabSection(
              tabController: _tabController,
              onTabChanged: () => setState(() {}),
            ),

            // Main Tab Content (Extracted Strategy: Lazy Content Switch)
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
      bottomNavigationBar: DashboardBottomNav(
        controller: _controller,
        onUpdate: () => setState(() {}),
      ),
    );
  }
}
