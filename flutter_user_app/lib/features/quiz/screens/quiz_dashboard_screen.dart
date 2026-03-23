import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import '../controllers/quiz_dashboard_controller.dart';
import 'widgets/dashboard/stats_summary_card.dart';
import 'widgets/dashboard/performance_trends_chart.dart';
import 'widgets/dashboard/quiz_mode_selector.dart';
import 'widgets/dashboard/dashboard_skeleton.dart';

class QuizDashboardScreen extends StatefulWidget {
  const QuizDashboardScreen({super.key});

  @override
  State<QuizDashboardScreen> createState() => _QuizDashboardScreenState();
}

class _QuizDashboardScreenState extends State<QuizDashboardScreen> {
  final QuizDashboardController _controller = QuizDashboardController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await _controller.init(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('기출문제 퀴즈 (통계)', style: AppTypography.titleMedium),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const DashboardSkeleton();
    }

    if (_controller.errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatsSummaryCard(
              overallAccuracy: _controller.overallAccuracy,
              totalAttempts: _controller.totalAttempts,
            ),
            const SizedBox(height: 24),
            PerformanceTrendsChart(trends: _controller.trends),
            const SizedBox(height: 24),
            const QuizModeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            '통계를 불러오지 못했습니다.\n${_controller.errorMessage}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('다시 시도', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
