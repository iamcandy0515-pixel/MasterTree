import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import '../utils/dashboard_layout_helper.dart';

/// Sliver Dashboard Tab Section (Strategy: Partial Splitting)
/// Isolated tab bar and its persistent header delegate.
class DashboardTabSection extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onTabChanged;

  const DashboardTabSection({
    super.key,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        TabBar(
          controller: tabController,
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
          onTap: (index) => onTabChanged(),
        ),
      ),
    );
  }
}
