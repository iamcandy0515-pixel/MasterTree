import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_detail_viewmodel.dart';
import '../widgets/user_detail/stats_colors.dart';
import '../widgets/user_detail/admin_overall_stats_tab.dart';
import '../widgets/user_detail/admin_quiz_stats_tab.dart';
import '../widgets/user_detail/admin_past_exam_stats_tab.dart';

class UserDetailStatsScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserDetailStatsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserDetailViewModel(userId)..loadStats(),
      child: _UserDetailStatsContent(userName: userName),
    );
  }
}

class _UserDetailStatsContent extends StatelessWidget {
  final String userName;
  const _UserDetailStatsContent({required this.userName});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserDetailViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: StatsColors.background,
        appBar: AppBar(
          backgroundColor: StatsColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '상세 학습 통계',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: const TabBar(
            indicatorColor: StatsColors.primary,
            labelColor: StatsColors.primary,
            unselectedLabelColor: Colors.white38,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: '종합'),
              Tab(text: '수목퀴즈'),
              Tab(text: '기출문제'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: vm.loadStats,
            ),
          ],
        ),
        body: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: StatsColors.primary),
              )
            : vm.error != null
            ? _buildErrorView(vm.error!)
            : vm.stats == null
            ? const Center(
                child: Text(
                  '데이터가 없습니다.',
                  style: TextStyle(color: Colors.white24),
                ),
              )
            : TabBarView(
                children: [
                  AdminOverallStatsTab(stats: vm.stats!),
                  AdminQuizStatsTab(stats: vm.stats!, categories: vm.categoryStats),
                  AdminPastExamStatsTab(stats: vm.stats!, exams: vm.examStats),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              '에러: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
